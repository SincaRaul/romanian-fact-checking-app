import os
from redis import Redis
from rq import Queue, Worker, Connection
from sqlalchemy.orm import Session
from datetime import datetime
import uuid

from app.settings import settings
from app.db import SessionLocal
from app import models

# Queue helpers
redis_conn = Redis.from_url(settings.REDIS_URL)
queue = Queue("build_check", connection=redis_conn)

def enqueue_build_check(question_id: str):
    queue.enqueue(run_build_check, question_id, job_timeout=600)

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
    with Connection(redis_conn):
        worker = Worker(["build_check"])  # ascultă coada respectivă
        worker.work()
