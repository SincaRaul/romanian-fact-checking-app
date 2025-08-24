from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
import uuid
from app.db import get_db
from app import models, schemas
from app.settings import settings
from app.worker import enqueue_build_check
from app.deps import device_id_header

router = APIRouter(prefix="/questions", tags=["questions"])

@router.post("", response_model=schemas.QuestionOut, status_code=status.HTTP_201_CREATED)
def create_question(payload: schemas.QuestionCreate, db: Session = Depends(get_db)):
    q = models.Question(
        id=f"q_{uuid.uuid4().hex[:10]}",
        title=payload.title.strip(),
        body=(payload.body or '').strip() or None,
        status="open",
        votes_count=0,
        created_at=datetime.utcnow(),
    )
    db.add(q)
    db.commit(); db.refresh(q)
    return q

@router.get("", response_model=list[schemas.QuestionOut])
def list_questions(db: Session = Depends(get_db), limit: int = 50, status_filter: str | None = None):
    query = db.query(models.Question).order_by(models.Question.created_at.desc())
    if status_filter:
        query = query.filter(models.Question.status == status_filter)
    return query.limit(limit).all()

@router.post("/{question_id}/vote", response_model=schemas.VoteOut)
def vote_question(
    question_id: str,
    db: Session = Depends(get_db),
    device_id: str | None = Depends(device_id_header),
):
    q = db.query(models.Question).get(question_id)
    if not q:
        raise HTTPException(status_code=404, detail="Question not found")

    # MVP: nu validăm încă unicitatea pe device; incrementăm simplu
    q.votes_count += 1

    # Prag → pune job și marchează queued
    if q.votes_count >= settings.VOTE_THRESHOLD and q.status == "open":
        q.status = "queued"
        db.commit()
        enqueue_build_check(question_id=q.id)
    else:
        db.commit()

    return schemas.VoteOut(question_id=q.id, votes_count=q.votes_count, status=q.status)
