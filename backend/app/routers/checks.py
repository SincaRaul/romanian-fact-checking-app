from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.db import get_db
from app import models, schemas
from typing import Optional

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
