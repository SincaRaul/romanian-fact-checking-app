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

class SupportTicketCreate(BaseModel):
    category: str
    description: str = Field(min_length=10)
    sourceUrl: Optional[str] = None
    userEmail: Optional[str] = None
    factCheckId: Optional[str] = None

class SupportTicketResponse(BaseModel):
    id: str
    category: str
    description: str
    sourceUrl: Optional[str]
    userEmail: Optional[str]
    factCheckId: Optional[str]
    createdAt: datetime

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

class CreateFactCheckRequest(BaseModel):
    title: str = Field(min_length=10, max_length=500, description="The title of the fact-check")
    verdict: str = Field(description="The verdict: true, false, mixed, or unclear")
    confidence: int = Field(ge=0, le=100, description="Confidence percentage (0-100)")
    summary: str = Field(min_length=50, description="The detailed explanation")
    category: str = Field(description="The category of the fact-check")
    sources: Optional[List[str]] = Field(default=None, description="List of sources")
