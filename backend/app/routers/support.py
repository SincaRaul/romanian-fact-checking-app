# backend/app/routers/support.py
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List
import json
import os
from datetime import datetime

from ..db import get_db
from ..schemas import SupportTicketCreate, SupportTicketResponse

router = APIRouter(prefix="/support", tags=["support"])

# File paths for storing support tickets
INCORRECT_INFO_FILE = "data/incorrect_info.json"
BUG_REPORTS_FILE = "data/bug_reports.json"
FEATURE_REQUESTS_FILE = "data/feature_requests.json"
GENERAL_QUESTIONS_FILE = "data/general_questions.json"
GENERAL_SUPPORT_FILE = "data/general_support.json"

def ensure_data_directory():
    """Ensure the data directory exists"""
    os.makedirs("data", exist_ok=True)

def load_tickets_from_file(filepath: str) -> List[dict]:
    """Load tickets from JSON file"""
    if not os.path.exists(filepath):
        return []
    
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            return json.load(f)
    except (json.JSONDecodeError, FileNotFoundError):
        return []

def save_ticket_to_file(filepath: str, ticket: dict):
    """Save ticket to JSON file"""
    print(f"[DEBUG] Attempting to save to: {filepath}")
    print(f"[DEBUG] Current working directory: {os.getcwd()}")
    print(f"[DEBUG] File exists before save: {os.path.exists(filepath)}")
    
    tickets = load_tickets_from_file(filepath)
    print(f"[DEBUG] Loaded {len(tickets)} existing tickets")
    
    tickets.append(ticket)
    
    try:
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(tickets, f, ensure_ascii=False, indent=2)
        print(f"[DEBUG] Successfully wrote {len(tickets)} tickets to {filepath}")
    except Exception as e:
        print(f"[ERROR] Failed to write to file: {e}")
        raise

def get_file_for_category(category: str) -> str:
    """Get the appropriate file path for the ticket category"""
    category_files = {
        "incorrectInfo": "data/incorrect_info.json",
        "bugReport": "data/bug_reports.json", 
        "featureRequest": "data/feature_requests.json",
        "generalQuestion": "data/general_questions.json"
    }
    
    return category_files.get(category, "data/general_support.json")

@router.post("/tickets")
async def create_support_ticket(
    ticket_data: dict,
    db: Session = Depends(get_db)
):
    """Create a new support ticket"""
    try:
        print(f"[DEBUG] Received ticket data: {ticket_data}")
        ensure_data_directory()
        
        # Add timestamp if not present
        if "createdAt" not in ticket_data:
            ticket_data["createdAt"] = datetime.now().isoformat()
        
        # Get the appropriate file based on category
        category = ticket_data.get("category", "generalQuestion")
        filepath = get_file_for_category(category)
        
        print(f"[DEBUG] Category: {category}, Filepath: {filepath}")
        
        # Save to appropriate file
        save_ticket_to_file(filepath, ticket_data)
        
        print(f"[DEBUG] Successfully saved ticket to {filepath}")
        
        return {
            "message": "Ticket created successfully",
            "ticket_id": ticket_data.get("id"),
            "category": category
        }
        
    except Exception as e:
        print(f"[ERROR] Exception occurred: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error creating ticket: {str(e)}")

@router.get("/tickets/my")
async def get_user_tickets():
    """Get all tickets (for development purposes)"""
    try:
        ensure_data_directory()
        
        all_tickets = []
        
        # Load from all files
        for filepath in [INCORRECT_INFO_FILE, BUG_REPORTS_FILE, FEATURE_REQUESTS_FILE, GENERAL_QUESTIONS_FILE, GENERAL_SUPPORT_FILE]:
            tickets = load_tickets_from_file(filepath)
            all_tickets.extend(tickets)
        
        # Sort by creation date (newest first)
        all_tickets.sort(key=lambda x: x.get("createdAt", ""), reverse=True)
        
        return {"tickets": all_tickets}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching tickets: {str(e)}")

@router.get("/stats")
async def get_support_stats():
    """Get support ticket statistics"""
    try:
        ensure_data_directory()
        
        stats = {
            "incorrect_info": len(load_tickets_from_file(INCORRECT_INFO_FILE)),
            "bug_reports": len(load_tickets_from_file(BUG_REPORTS_FILE)),
            "feature_requests": len(load_tickets_from_file(FEATURE_REQUESTS_FILE)),
            "general_questions": len(load_tickets_from_file(GENERAL_QUESTIONS_FILE)),
            "general_support": len(load_tickets_from_file(GENERAL_SUPPORT_FILE)),
        }
        
        stats["total"] = sum(stats.values())
        
        return stats
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching stats: {str(e)}")
