cd C:\Licenta\flutter_application_1; git commit -m "🚀 Initial commit: Complete Romanian Fact-Checking App
Features implemented:
- Flutter frontend with Material Design 3
- FastAPI backend with PostgreSQL + Redis
- Complete category system with Romanian labels
- Docker containerization
- Riverpod state management
- GoRouter navigation
- API integration with error handling
- Seed data with categorized fact-checks

🗂️ Categories: Football, Politics, Health, Bills, Technology, etc.
🤖 AI ready: Gemini service prepared for auto-categorization
📱 Responsive: Web and mobile ready

Architecture: Flutter + FastAPI + PostgreSQL + Redis + Docker
Last updated: August 24, 2025"from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import get_db
from app import models
import uuid
from datetime import datetime, timedelta

router = APIRouter(prefix="/admin", tags=["admin"])

@router.post("/seed-data")
def seed_database(db: Session = Depends(get_db)):
    """Endpoint pentru a popula baza de date cu date de test."""
    
    # Ștergem datele existente pentru a începe curat
    db.query(models.Vote).delete()
    db.query(models.Check).delete()
    db.query(models.Question).delete()
    
    # Date de test pentru întrebări și fact-check-uri românești
    sample_questions = [
        {
            "id": str(uuid.uuid4()),
            "title": "România este membră NATO din 2004?",
            "body": "Am auzit că România a aderat la NATO în 2004. Este adevărat?",
            "status": "checked",
            "votes_count": 15
        },
        {
            "id": str(uuid.uuid4()),
            "title": "Bucureștiul este cel mai mare oraș din România?",
            "body": "Care este cel mai mare oraș din România după numărul de locuitori?",
            "status": "checked", 
            "votes_count": 23
        },
        {
            "id": str(uuid.uuid4()),
            "title": "Vaccinurile COVID-19 conțin cipuri de monitorizare?",
            "body": "Am citit pe Facebook că vaccinurile COVID-19 conțin cipuri pentru monitorizare. Este adevărat?",
            "status": "checked",
            "votes_count": 87
        },
        {
            "id": str(uuid.uuid4()),
            "title": "România exportă mai mult gaze naturale decât importă?",
            "body": "România este exportator net de gaze naturale?",
            "status": "checked",
            "votes_count": 12
        },
        {
            "id": str(uuid.uuid4()),
            "title": "Vitamina C previne răceala comună?",
            "body": "Dacă iau vitamina C zilnic, nu mă voi îmbolnăvi de răceală?",
            "status": "checked",
            "votes_count": 34
        }
    ]
    
    # Creează întrebările în baza de date
    questions = []
    for q_data in sample_questions:
        question = models.Question(
            id=q_data["id"],
            title=q_data["title"],
            body=q_data["body"],
            status=q_data["status"],
            votes_count=q_data["votes_count"],
            created_at=datetime.utcnow() - timedelta(days=10, hours=q_data["votes_count"])
        )
        questions.append(question)
        db.add(question)
    
    # Date pentru fact-check-uri
    sample_checks = [
        {
            "question_id": questions[0].id,
            "title": "România a aderat la NATO pe 29 martie 2004",
            "verdict": "true",
            "confidence": 95,
            "summary": "România a devenit oficial membră NATO pe 29 martie 2004, împreună cu Bulgaria, Estonia, Letonia, Lituania, Slovacia și Slovenia. Ceremonia oficială a avut loc la Washington D.C.",
            "category": "politics_external"
        },
        {
            "question_id": questions[1].id,
            "title": "Bucureștiul este cel mai mare oraș din România cu peste 1.8 milioane locuitori",
            "verdict": "true",
            "confidence": 90,
            "summary": "Conform recensământului din 2021, Bucureștiul are 1.883.425 locuitori, fiind cu mult cel mai mare oraș din România. Următorul oraș ca mărime este Cluj-Napoca cu aproximativ 286.000 locuitori.",
            "category": "other"
        },
        {
            "question_id": questions[2].id,
            "title": "Vaccinurile COVID-19 NU conțin cipuri de monitorizare",
            "verdict": "false",
            "confidence": 99,
            "summary": "Această afirmație este complet falsă și a fost demontată de numeroase organizații de fact-checking și autorități medicale. Vaccinurile COVID-19 conțin ARN mesager sau proteina spike, nu tehnologie de urmărire.",
            "category": "health"
        },
        {
            "question_id": questions[3].id,
            "title": "România importă mai multe gaze naturale decât exportă",
            "verdict": "false",
            "confidence": 85,
            "summary": "România este un importator net de gaze naturale. Deși are producție internă semnificativă din Marea Neagră și terestru, consumul depășește producția, necesitând importuri din Rusia și alte țări.",
            "category": "bills"
        },
        {
            "question_id": questions[4].id,
            "title": "Vitamina C nu previne răceala, dar poate reduce durata simptomelor",
            "verdict": "mixed",
            "confidence": 80,
            "summary": "Studiile arată că vitamina C nu previne răceala comună la majoritatea oamenilor. Totuși, poate reduce ușor durata și severitatea simptomelor dacă este luată regulat înainte de îmbolnăvire.",
            "category": "health"
        }
    ]
    
    # Creează fact-check-urile în baza de date
    for i, check_data in enumerate(sample_checks):
        check = models.Check(
            id=str(uuid.uuid4()),
            question_id=check_data["question_id"],
            title=check_data["title"],
            verdict=check_data["verdict"],
            confidence=check_data["confidence"],
            summary=check_data["summary"],
            category=check_data["category"],  # Adaugă categoria
            auto_generated=True,
            status="published",
            published_at=datetime.utcnow() - timedelta(days=8, hours=i),
            created_at=datetime.utcnow() - timedelta(days=9, hours=i)
        )
        db.add(check)
    
    # Salvează schimbările
    db.commit()
    
    # Verifică datele create
    total_questions = db.query(models.Question).count()
    total_checks = db.query(models.Check).count()
    
    return {
        "message": "Database seeded successfully!",
        "questions_created": len(questions),
        "checks_created": len(sample_checks),
        "total_questions": total_questions,
        "total_checks": total_checks
    }
