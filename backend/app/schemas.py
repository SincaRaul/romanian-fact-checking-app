from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List

class QuestionCreate(BaseModel):
    title: str = Field(min_length=5, max_length=280)
    body: Optional[str] = None

class QuestionOut(BaseModel):
    id: str
    title: str
    body: Optional[str]
    status: str
    votes_count: int
    created_at: datetime

    class Config:
        from_attributes = True

class VoteOut(BaseModel):
    question_id: str
    votes_count: int
    status: str

class CheckOut(BaseModel):
    id: str
    question_id: str
    title: str
    verdict: str
    confidence: int
    summary: Optional[str]
    category: Optional[str]
    sources: Optional[List[str]]
    auto_generated: bool
    published_at: Optional[datetime]

    class Config:
        from_attributes = True

class GenerateCheckRequest(BaseModel):
    question: str = Field(min_length=10, max_length=500, description="The question/claim to fact-check")
    category: Optional[str] = Field(None, description="Optional category hint for the AI")

class GenerateCheckResponse(BaseModel):
    id: str
    title: str
    verdict: str
    confidence: int
    summary: str
    category: str
    auto_generated: bool = True
    created_at: datetime
    sources: Optional[List[str]] = None
