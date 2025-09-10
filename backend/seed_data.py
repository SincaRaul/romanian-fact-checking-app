#!/usr/bin/env python3
"""
Script pentru a popula baza de date cu date de test pentru aplicația de fact-checking.
"""

import uuid
from datetime import datetime, timedelta
from sqlalchemy.orm import sessionmaker
from app.db import engine
from app import models

# Creează sesiunea
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

def create_sample_data():
    """Create test data in database."""
    
    db.query(models.Vote).delete()
    db.query(models.Check).delete()
    db.query(models.Question).delete()
    
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
    
    sample_checks = [
        {
            "question_id": questions[0].id,
            "title": "România a aderat la NATO pe 29 martie 2004",
            "verdict": "true",
            "confidence": 95,
            "summary": "România a devenit oficial membră NATO pe 29 martie 2004, împreună cu Bulgaria, Estonia, Letonia, Lituania, Slovacia și Slovenia. Ceremonia oficială a avut loc la Washington D.C."
        },
        {
            "question_id": questions[1].id,
            "title": "Bucureștiul este cel mai mare oraș din România cu peste 1.8 milioane locuitori",
            "verdict": "true",
            "confidence": 90,
            "summary": "Conform recensământului din 2021, Bucureștiul are 1.883.425 locuitori, fiind cu mult cel mai mare oraș din România. Următorul oraș ca mărime este Cluj-Napoca cu aproximativ 286.000 locuitori."
        },
        {
            "question_id": questions[2].id,
            "title": "Vaccinurile COVID-19 NU conțin cipuri de monitorizare",
            "verdict": "false",
            "confidence": 99,
            "summary": "Această afirmație este complet falsă și a fost demontată de numeroase organizații de fact-checking și autorități medicale. Vaccinurile COVID-19 conțin ARN mesager sau proteina spike, nu tehnologie de urmărire."
        },
        {
            "question_id": questions[3].id,
            "title": "România importă mai multe gaze naturale decât exportă",
            "verdict": "false",
            "confidence": 85,
            "summary": "România este un importator net de gaze naturale. Deși are producție internă semnificativă din Marea Neagră și terestru, consumul depășește producția, necesitând importuri din Rusia și alte țări."
        },
        {
            "question_id": questions[4].id,
            "title": "Vitamina C nu previne răceala, dar poate reduce durata simptomelor",
            "verdict": "mixed",
            "confidence": 80,
            "summary": "Studiile arată că vitamina C nu previne răceala comună la majoritatea oamenilor. Totuși, poate reduce ușor durata și severitatea simptomelor dacă este luată regulat înainte de îmbolnăvire."
        }
    ]
    
    for i, check_data in enumerate(sample_checks):
        check = models.Check(
            id=str(uuid.uuid4()),
            question_id=check_data["question_id"],
            title=check_data["title"],
            verdict=check_data["verdict"],
            confidence=check_data["confidence"],
            summary=check_data["summary"],
            auto_generated=True,
            status="published",
            published_at=datetime.utcnow() - timedelta(days=8, hours=i),
            created_at=datetime.utcnow() - timedelta(days=9, hours=i)
        )
        db.add(check)
    
    # Salvează schimbările
    db.commit()
    print(f"✅ Created {len(questions)} questions and {len(sample_checks)} fact-checks")
    
    # Verifică datele create
    total_questions = db.query(models.Question).count()
    total_checks = db.query(models.Check).count()
    print(f"📊 Total in database: {total_questions} questions, {total_checks} checks")

if __name__ == "__main__":
    try:
        create_sample_data()
        print("🎉 Sample data created successfully!")
    except Exception as e:
        print(f"❌ Error creating sample data: {e}")
        db.rollback()
    finally:
        db.close()
