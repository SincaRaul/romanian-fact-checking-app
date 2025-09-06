from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.db import get_db
from app import models, schemas
from app.services.gemini_service import gemini_service
from typing import Optional
from datetime import datetime
import uuid

router = APIRouter(prefix="", tags=["checks"])

@router.get("/fact-checks", response_model=list[schemas.CheckOut])
def latest_checks(
    db: Session = Depends(get_db), 
    limit: int = 20,
    category: Optional[str] = Query(None, description="Filter by single category"),
    categories: Optional[str] = Query(None, description="Filter by multiple categories (comma-separated)")
):
    query = (
        db.query(models.Check)
        .filter(models.Check.status.in_(["draft", "published"]))
    )
    
    # Add category filter if provided
    if categories:
        # Support multiple categories: "politics_internal,health,football"
        category_list = [cat.strip() for cat in categories.split(",")]
        query = query.filter(models.Check.category.in_(category_list))
    elif category:
        # Backward compatibility for single category
        query = query.filter(models.Check.category == category)
    
    rows = query.order_by(models.Check.created_at.desc()).limit(limit).all()
    return rows

@router.get("/checks/{check_id}", response_model=schemas.CheckOut)
def get_check(check_id: str, db: Session = Depends(get_db)):
    c = db.query(models.Check).get(check_id)
    if not c:
        raise HTTPException(status_code=404, detail="Check not found")
    return c

@router.get("/categories", response_model=list[dict])
def get_categories():
    """Get all available categories with Romanian labels"""
    return [
        {"id": "football", "label": "Fotbal", "icon": "⚽"},
        {"id": "politics_internal", "label": "Politică Internă", "icon": "🏛️"},
        {"id": "politics_external", "label": "Politică Externă", "icon": "🌍"},
        {"id": "bills", "label": "Facturi și Utilități", "icon": "💰"},
        {"id": "health", "label": "Sănătate", "icon": "🏥"},
        {"id": "technology", "label": "Tehnologie", "icon": "💻"},
        {"id": "environment", "label": "Mediu", "icon": "🌱"},
        {"id": "economy", "label": "Economie", "icon": "📈"},
        {"id": "other", "label": "Altele", "icon": "📰"}
    ]

@router.post("/generate", response_model=schemas.GenerateCheckResponse)
async def generate_fact_check(
    request: schemas.GenerateCheckRequest,
    db: Session = Depends(get_db)
):
    """Generate a new fact-check using AI"""
    try:
        # Generate fact-check using Gemini AI
        ai_result = await gemini_service.generate_fact_check(request.question)
        
        # Override category if user provided one
        if request.category:
            ai_result["category"] = request.category
        
        # Create a new Check record in database
        check_id = str(uuid.uuid4())
        
        # Create a dummy question first (since Check requires question_id)
        question = models.Question(
            id=str(uuid.uuid4()),
            title=request.question,
            body=None,
            status="published",
            votes_count=0,
            created_at=datetime.utcnow()
        )
        db.add(question)
        db.flush()  # Get the question ID
        
        # Create the fact-check
        new_check = models.Check(
            id=check_id,
            question_id=question.id,
            title=request.question,
            verdict=ai_result["verdict"],
            confidence=ai_result["confidence"],
            summary=ai_result["summary"],
            category=ai_result["category"],
            sources=ai_result.get("sources", []),
            auto_generated=True,
            status="published",
            published_at=datetime.utcnow(),
            created_at=datetime.utcnow()
        )
        
        db.add(new_check)
        db.commit()
        db.refresh(new_check)
        
        return schemas.GenerateCheckResponse(
            id=new_check.id,
            title=new_check.title,
            verdict=new_check.verdict,
            confidence=new_check.confidence,
            summary=new_check.summary,
            category=new_check.category,
            auto_generated=new_check.auto_generated,
            created_at=new_check.created_at,
            sources=new_check.sources
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Eroare la generarea fact-check-ului: {str(e)}"
        )
