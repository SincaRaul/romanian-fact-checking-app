# backend/app/routers/analytics.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, constr, Field
from datetime import datetime, timezone, timedelta
from typing import Literal, Optional, List, Dict
import math
import redis
import json
import os
from ..db import get_db
from sqlalchemy.orm import Session
from sqlalchemy import text

router = APIRouter()

# Redis connection
redis_host = os.getenv("REDIS_HOST", "redis")  # Default to 'redis' for Docker
redis_port = int(os.getenv("REDIS_PORT", "6379"))

try:
    r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)
    r.ping()  # Test connection
    print(f"✅ Connected to Redis at {redis_host}:{redis_port}")
except Exception as e:
    print(f"❌ Redis connection failed: {e}")
    r = None

class Event(BaseModel):
    type: Literal["open", "read_complete", "share", "search"]
    fact_check_id: Optional[constr(strip_whitespace=True, min_length=1)] = None
    uid: constr(strip_whitespace=True, min_length=8)
    ts: Optional[datetime] = None
    query: Optional[str] = None  # For search events
    result_count: Optional[int] = None  # For search events

@router.post("/events", status_code=204)
async def ingest_event(event: Event):
    """Ingest user interaction events for analytics"""
    if not r:
        # Silently ignore if Redis not available
        return
    
    try:
        ts = int((event.ts or datetime.now(timezone.utc)).timestamp())
        hour_key = datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y%m%d%H")
        
        pipe = r.pipeline()
        
        if event.type in ["open", "read_complete", "share"] and event.fact_check_id:
            # HyperLogLog bucket per hour (kept 48h)
            hll_key = f"fc:{event.fact_check_id}:hll:{hour_key}"
            pipe.pfadd(hll_key, event.uid)
            pipe.expire(hll_key, 60*60*48)  # 48 hour retention
            
            # Touch candidate set so the scorer knows what to recompute
            pipe.zincrby("hot:candidates", 1, event.fact_check_id)
            
            # For engagement events, give higher weight
            if event.type in ["read_complete", "share"]:
                pipe.zincrby("hot:candidates", 2, event.fact_check_id)
                
        elif event.type == "search" and event.query:
            # Track search queries for trending topics
            search_key = f"search:{hour_key}"
            pipe.hincrby(search_key, event.query.lower(), 1)
            pipe.expire(search_key, 60*60*24)  # 24 hour retention
        
        await pipe.execute()
        
    except Exception as e:
        print(f"Analytics error: {e}")
        # Don't raise - analytics failures shouldn't break user experience

async def hll_unique_count(fact_check_id: str, hours: int, now: datetime) -> int:
    """Get approximate unique users for a fact-check in the last N hours"""
    if not r:
        return 0
        
    keys = []
    for i in range(hours):
        hour_key = (now - timedelta(hours=i)).strftime("%Y%m%d%H")
        keys.append(f"fc:{fact_check_id}:hll:{hour_key}")
    
    if not keys:
        return 0
        
    # Use a temporary key for merging
    import uuid
    tmp_key = f"tmp:hll:{fact_check_id}:{hours}:{uuid.uuid4().hex[:8]}"
    
    try:
        r.pfmerge(tmp_key, *keys)
        count = r.pfcount(tmp_key)
        r.delete(tmp_key)
        return int(count)
    except:
        return 0

async def get_fact_check_created_at(fact_check_id: str) -> datetime:
    """Get the created timestamp for a fact-check"""
    try:
        # Mock for now - in production, query your database
        # For now, assume created 1-24 hours ago randomly based on ID hash
        hash_val = hash(fact_check_id) % 24
        return datetime.now(timezone.utc) - timedelta(hours=hash_val)
    except:
        return datetime.now(timezone.utc) - timedelta(hours=12)

async def compute_hot_score(fact_check_id: str, now: datetime) -> float:
    """Compute hot score for a fact-check using time decay and engagement"""
    uni_2h = await hll_unique_count(fact_check_id, 2, now)
    uni_24h = await hll_unique_count(fact_check_id, 24, now)
    
    created_at = await get_fact_check_created_at(fact_check_id)
    age_hours = max(0.0, (now - created_at).total_seconds() / 3600.0)
    
    # Enhanced formula: more weight on recent activity, faster decay
    score = (uni_2h * 5 + uni_24h * 2) * math.exp(-age_hours / 24.0)
    return score

@router.post("/compute-hot")
async def recompute_hot_scores():
    """Recompute hot scores for all candidate fact-checks"""
    if not r:
        return {"status": "Redis not available"}
        
    now = datetime.now(timezone.utc)
    
    try:
        # Get all candidates that have had recent activity
        candidates = r.zrange("hot:candidates", 0, -1)
        
        scores = {}
        for fact_check_id in candidates:
            score = await compute_hot_score(fact_check_id, now)
            scores[fact_check_id] = score
        
        # Update the hot ranking
        if scores:
            r.zadd("hot:24h", scores)
            r.expire("hot:24h", 60*10)  # 10 minute expiry
            
        return {
            "status": "success", 
            "computed": len(scores),
            "top_scores": dict(sorted(scores.items(), key=lambda x: x[1], reverse=True)[:5])
        }
        
    except Exception as e:
        return {"status": "error", "message": str(e)}

@router.get("/fact-checks/hot")
async def get_hot_fact_checks(limit: int = 10) -> List[Dict]:
    """Get the hottest/trending fact-checks"""
    if not r:
        # Fallback to a simple query if Redis not available
        return []
    
    try:
        # Get hot fact-check IDs in order
        hot_ids = r.zrevrange("hot:24h", 0, limit-1)
        
        if not hot_ids:
            # If no hot data, return recent fact-checks as fallback
            return []
            
        # Mock data for now - in production, fetch from your database
        # preserving the hot order
        mock_fact_checks = []
        for i, fact_check_id in enumerate(hot_ids):
            mock_fact_checks.append({
                "id": fact_check_id,
                "title": f"Hot Fact-Check #{i+1}: {fact_check_id}",
                "verdict": "true" if i % 2 == 0 else "false",
                "confidence": 85 + (i * 2),
                "publishedAt": (datetime.now(timezone.utc) - timedelta(hours=i+1)).isoformat(),
                "category": ["health", "politics_internal", "football", "environment"][i % 4],
                "summary": f"This is a trending fact-check that users are actively engaging with.",
                "autoGenerated": False,
                "sources": [f"Source {i+1}", f"Source {i+2}"]
            })
            
        return mock_fact_checks
        
    except Exception as e:
        print(f"Hot fact-checks error: {e}")
        return []

@router.get("/analytics/trending-searches")
async def get_trending_searches(hours: int = 24) -> List[Dict[str, str|int]]:
    """Get trending search queries"""
    if not r:
        return []
        
    try:
        now = datetime.now(timezone.utc)
        all_searches = {}
        
        # Aggregate searches from last N hours
        for i in range(hours):
            hour_key = (now - timedelta(hours=i)).strftime("%Y%m%d%H")
            search_key = f"search:{hour_key}"
            
            searches = r.hgetall(search_key)
            for query, count in searches.items():
                all_searches[query] = all_searches.get(query, 0) + int(count)
        
        # Sort by popularity and return top results
        trending = sorted(all_searches.items(), key=lambda x: x[1], reverse=True)[:20]
        return [{"query": query, "count": count} for query, count in trending]
        
    except Exception as e:
        print(f"Trending searches error: {e}")
        return []
