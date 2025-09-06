from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db import Base

class Question(Base):
    __tablename__ = "questions"
    id = Column(String, primary_key=True)
    title = Column(String(280), nullable=False)
    body = Column(Text, nullable=True)
    status = Column(String(20), default="open")  # open|queued|checked
    votes_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)

    checks = relationship("Check", back_populates="question")

class Check(Base):
    __tablename__ = "checks"
    id = Column(String, primary_key=True)
    question_id = Column(String, ForeignKey("questions.id"), nullable=False)
    title = Column(String(280), nullable=False)
    verdict = Column(String(16), nullable=False)  # true|false|mixed|unclear
    confidence = Column(Integer, default=0)
    summary = Column(Text, nullable=True)
    category = Column(String(50), nullable=True)  # football|politics_internal|politics_external|bills|health|tech|other
    sources = Column(JSON, nullable=True)  # array de surse în format JSON
    auto_generated = Column(Boolean, default=True)
    status = Column(String(16), default="draft") # draft|published
    published_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    question = relationship("Question", back_populates="checks")

class Vote(Base):
    __tablename__ = "votes"
    id = Column(String, primary_key=True)
    question_id = Column(String, ForeignKey("questions.id"), nullable=False)
    device_id = Column(String(64), nullable=True)  # simplu pentru MVP
    created_at = Column(DateTime, default=datetime.utcnow)
