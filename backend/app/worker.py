import os
import asyncio
import time
from redis import Redis
from rq import Queue, Worker, Connection
from sqlalchemy.orm import Session
from datetime import datetime, timezone
import uuid

from app.settings import settings
from app.db import SessionLocal
from app import models

# Queue helpers
redis_conn = Redis.from_url(settings.REDIS_URL)
queue = Queue("build_check", connection=redis_conn)

def enqueue_build_check(question_id: str):
    queue.enqueue(run_build_check, question_id, job_timeout=600)

# Analytics helper functions
async def compute_hot_score(fact_check_id: str, now: datetime) -> float:
    """Compute hot score for a fact-check using time decay and engagement"""
    try:
        from app.routers.analytics import hll_unique_count, get_fact_check_created_at
        import math
        
        uni_2h = await hll_unique_count(fact_check_id, 2, now)
        uni_24h = await hll_unique_count(fact_check_id, 24, now)
        
        created_at = await get_fact_check_created_at(fact_check_id)
        age_hours = max(0.0, (now - created_at).total_seconds() / 3600.0)
        
        # Enhanced formula: more weight on recent activity, faster decay
        score = (uni_2h * 5 + uni_24h * 2) * math.exp(-age_hours / 24.0)
        return score
    except Exception as e:
        print(f"Error computing hot score for {fact_check_id}: {e}")
        return 0.0

async def recompute_hot_scores():
    """Background task to recompute hot scores every 2 minutes"""
    r = redis_conn
    now = datetime.now(timezone.utc)
    
    try:
        # Get all candidates that have had recent activity
        candidates = r.zrange("hot:candidates", 0, -1)
        
        if not candidates:
            print("📊 No hot candidates found")
            return
            
        scores = {}
        for fact_check_id in candidates:
            if isinstance(fact_check_id, bytes):
                fact_check_id = fact_check_id.decode('utf-8')
            score = await compute_hot_score(fact_check_id, now)
            scores[fact_check_id] = score
        
        # Update the hot ranking
        if scores:
            r.zadd("hot:24h", scores)
            r.expire("hot:24h", 60*15)  # 15 minute expiry
            
            top_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)[:3]
            print(f"🔥 Updated hot scores for {len(scores)} fact-checks. Top 3: {top_scores}")
        else:
            print("📊 No scores computed")
            
    except Exception as e:
        print(f"❌ Error computing hot scores: {e}")

async def cleanup_old_data():
    """Clean up old analytics data every hour"""
    r = redis_conn
    
    try:
        # Clean up candidates that haven't been active recently
        # Remove candidates with score < 1 (very low activity)
        removed = r.zremrangebyscore("hot:candidates", 0, 1)
        if removed:
            print(f"🧹 Cleaned up {removed} inactive candidates")
            
    except Exception as e:
        print(f"❌ Error during cleanup: {e}")

async def analytics_worker():
    """Analytics worker loop"""
    print("🚀 Starting analytics worker...")
    
    last_cleanup = time.time()
    
    while True:
        try:
            # Recompute hot scores every 2 minutes
            await recompute_hot_scores()
            
            # Cleanup every hour
            if time.time() - last_cleanup > 3600:  # 1 hour
                await cleanup_old_data()
                last_cleanup = time.time()
                
            # Wait 2 minutes before next run
            await asyncio.sleep(120)
            
        except KeyboardInterrupt:
            print("🛑 Analytics worker stopped by user")
            break
        except Exception as e:
            print(f"❌ Analytics worker error: {e}")
            await asyncio.sleep(30)  # Wait 30s before retry

# Job logic (MVP placeholder): creează un check "unclear"

def run_build_check(question_id: str):
    db: Session = SessionLocal()
    try:
        q = db.query(models.Question).get(question_id)
        if not q:
            return
        # Dacă există deja un check, nu mai crea
        exists = db.query(models.Check).filter(models.Check.question_id == q.id).first()
        if exists:
            return
        c = models.Check(
            id=f"c_{uuid.uuid4().hex[:10]}",
            question_id=q.id,
            title=q.title,
            verdict="unclear",
            confidence=0,
            summary=None,
            auto_generated=True,
            status="draft",
            published_at=None,
            created_at=datetime.utcnow(),
        )
        q.status = "checked"  # sau rămâne queued până la publish manual
        db.add(c)
        db.commit()
    finally:
        db.close()

# Rulare worker (doar în containerul worker)
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "analytics":
        # Run only analytics worker
        print("🚀 Starting Analytics worker...")
        asyncio.run(analytics_worker())
    else:
        # Default: run only RQ worker (existing behavior)
        print("🚀 Starting RQ worker...")
        with Connection(redis_conn):
            worker = Worker(["build_check"])
            worker.work()
