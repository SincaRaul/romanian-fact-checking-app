from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import List, Optional
import uuid
from datetime import datetime
import logging

from app.db import get_db
from app import models
from app.auth_admin import admin_required

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/admin")

class CreateFactCheck(BaseModel):
    title: str = Field(min_length=10, max_length=500, description="The title of the fact-check")
    verdict: str = Field(description="The verdict: true, false, mixed, or unclear")
    confidence: int = Field(ge=0, le=100, description="Confidence percentage (0-100)")
    summary: str = Field(min_length=50, description="The detailed explanation")
    category: str = Field(description="The category of the fact-check")
    sources: Optional[List[str]] = Field(default=None, description="List of sources")

@router.post("/fact-checks", status_code=201)
async def create_fact_check(
    fc: CreateFactCheck,
    db: Session = Depends(get_db),
    _=Depends(admin_required)
):
    """Create a new fact-check manually (admin only)"""
    try:
        # Create a dummy question first (since Check requires question_id)
        question = models.Question(
            id=str(uuid.uuid4()),
            title=fc.title,
            body=None,
            status="checked"
        )
        db.add(question)
        
        # Create the fact-check
        check_id = str(uuid.uuid4())
        check = models.Check(
            id=check_id,
            question_id=question.id,
            title=fc.title,
            verdict=fc.verdict,
            confidence=fc.confidence,
            summary=fc.summary,
            category=fc.category,
            sources=fc.sources,
            auto_generated=False,  # Manual fact-check
            status="published",
            published_at=datetime.utcnow()
        )
        db.add(check)
        db.commit()
        db.refresh(check)
        
        logger.info(f"Admin created fact-check: {check_id}")
        return check
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating admin fact-check: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error creating fact-check: {str(e)}")

@router.get("/fact-checks")
async def list_fact_checks(
    db: Session = Depends(get_db),
    _=Depends(admin_required)
):
    """List all fact-checks (admin only)"""
    checks = db.query(models.Check).order_by(models.Check.created_at.desc()).all()
    return checks
