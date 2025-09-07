import os
import time
import hmac
import hashlib
import jwt
from fastapi import APIRouter, HTTPException, Depends, Request, Header
from pydantic import BaseModel
from redis.asyncio import Redis
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth/admin")
JWT_SECRET = os.getenv("JWT_SECRET", "change-me-in-production")
ADMIN_PASS_SHA256 = os.getenv("ADMIN_PASS_SHA256")  # store sha256 of passcode

# Redis connection
r = Redis(host="redis", port=6379, decode_responses=True)

class AdminLogin(BaseModel):
    passcode: str

async def rate_limit(req: Request, key: str, limit: int, ttl: int):
    """Rate limiting to prevent brute force attacks"""
    ip = req.client.host
    rk = f"rl:{key}:{ip}"
    try:
        c = await r.incr(rk)
        if c == 1:
            await r.expire(rk, ttl)
        if c > limit:
            raise HTTPException(429, "Too many attempts")
    except Exception as e:
        logger.warning(f"Rate limiting failed: {e}")
        # Continue without rate limiting if Redis fails

@router.post("/login")
async def login(payload: AdminLogin, req: Request):
    """Admin login endpoint"""
    await rate_limit(req, "admin_login", limit=10, ttl=300)  # 10 tries / 5min
    
    if not ADMIN_PASS_SHA256:
        raise HTTPException(500, "Admin not configured")
    
    # Secure comparison
    provided_hash = hashlib.sha256(payload.passcode.encode()).hexdigest()
    is_valid = hmac.compare_digest(provided_hash, ADMIN_PASS_SHA256)
    
    if not is_valid:
        logger.warning(f"Failed admin login attempt from {req.client.host}")
        raise HTTPException(401, "Invalid passcode")
    
    # Create JWT token
    token = jwt.encode({
        "role": "admin",
        "iat": int(time.time()),
        "exp": int(time.time()) + 3600  # 1 hour expiry
    }, JWT_SECRET, algorithm="HS256")
    
    logger.info(f"Admin login successful from {req.client.host}")
    return {"access_token": token, "token_type": "bearer"}

def admin_required(authorization: str = Header(default="")):
    """Dependency to require admin authentication"""
    if not authorization.startswith("Bearer "):
        raise HTTPException(401, "Missing token")
    
    token = authorization.split(" ", 1)[1]
    try:
        claims = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        raise HTTPException(401, "Token expired")
    except Exception:
        raise HTTPException(401, "Invalid token")
    
    if claims.get("role") != "admin":
        raise HTTPException(403, "Forbidden")
    
    return claims
