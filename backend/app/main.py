from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.settings import cors_origins_list
from app.db import Base, engine
from app.routers import questions, checks, admin

# Creează tabelele la pornire (MVP). Pentru producție -> Alembic.
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Factual Clone API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Pentru dezvoltare - în producție să fie mai restrictiv  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(questions.router)
app.include_router(checks.router)
app.include_router(admin.router)

@app.get("/")
def root():
    return {"ok": True}
