# 🇷🇴 Romanian Fact-Checking App

Aplicație completă de fact-checking pentru știrile din România, construită cu Flutter (frontend) și FastAPI (backend).

## 🚀 Features Implementate

### ✅ Frontend (Flutter)
- **🎨 Design modern** cu Material Design 3
- **🔍 Căutare și filtrare** fact-check-uri
- **📱 Responsive UI** pentru web și mobile
- **🗂️ Categorii** pentru organizarea conținutului
- **📄 Pagini detaliate** pentru fiecare fact-check
- **🎯 Navigare cu GoRouter**
- **⚡ State management cu Riverpod**

### ✅ Backend (FastAPI + PostgreSQL)
- **🔧 REST API complet** cu documentație automată
- **🗃️ Baza de date PostgreSQL** cu relații complexe
- **🐳 Docker containerization** pentru development
- **📊 Sistem de categorii** pentru organizarea conținutului
- **🤖 Integrare Gemini AI** pentru categorizare automată
- **⚡ Redis pentru caching** și queue management
- **🔒 CORS configurat** pentru frontend

### 🗂️ Categorii Disponibile
- **⚽ Fotbal** - știri sportive
- **🏛️ Politică Internă** - politica românească
- **🌍 Politică Externă** - relații internaționale
- **💰 Facturi și Utilități** - economie personală
- **🏥 Sănătate** - informații medicale
- **💻 Tehnologie** - inovații tech
- **🌱 Mediu** - ecologie și natură
- **📈 Economie** - piața și finanțe
- **📰 Altele** - diverse subiecte

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.35.1** - UI framework
- **Riverpod 2.5.1** - State management
- **GoRouter 14.2.0** - Navigation
- **Dio** - HTTP client
- **JSON Serialization** pentru modele

### Backend
- **FastAPI** - Python web framework
- **PostgreSQL 15** - Baza de date principală
- **Redis 7** - Caching și queue
- **SQLAlchemy** - ORM
- **Pydantic** - Validare date
- **Google Gemini AI** - Categorizare automată
- **Docker & Docker Compose** - Containerization

## 🚀 Instalare și Rulare

### Prerequisites
- Flutter SDK 3.35.1+
- Docker & Docker Compose
- Python 3.11+ (pentru development local)
- Chrome browser (pentru web)

### 1. Clonează repository
\`\`\`bash
git clone <repo-url>
cd flutter_application_1
\`\`\`

### 2. Backend Setup
\`\`\`bash
cd backend
docker-compose up -d
\`\`\`

Verifică că serviciile rulează:
\`\`\`bash
docker-compose ps
\`\`\`

### 3. Seed Data (Prima rulare)
\`\`\`bash
# Accesează http://localhost:8000/docs
# Sau folosește:
curl -X POST http://localhost:8000/admin/seed-data
\`\`\`

### 4. Frontend Setup
\`\`\`bash
cd ..
flutter pub get
flutter run -d chrome
\`\`\`

## 📡 API Endpoints

### Core Endpoints
- \`GET /fact-checks\` - Lista fact-check-uri (cu filtrare)
- \`GET /fact-checks?category=health\` - Filtrare pe categorie
- \`GET /checks/{id}\` - Detalii fact-check specific
- \`GET /categories\` - Lista categoriilor disponibile
- \`POST /admin/seed-data\` - Reset date de test

### API Documentation
Accesează documentația interactivă la: \`http://localhost:8000/docs\`

## 🏗️ Arhitectura Proiectului

\`\`\`
flutter_application_1/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── data/                     # Repository layer
│   │   ├── api_fact_check_repository.dart
│   │   └── fact_check_repository_interface.dart
│   ├── models/                   # Data models
│   │   ├── fact_check.dart
│   │   ├── check.dart
│   │   └── question.dart
│   ├── providers/                # Riverpod providers
│   │   └── fact_check_providers.dart
│   ├── screens/                  # UI screens
│   │   └── fact_check_details_screen.dart
│   ├── services/                 # API services
│   │   ├── api_service.dart
│   │   ├── fact_checks_api.dart
│   │   └── questions_api.dart
│   └── utils/                    # Utilities
│       └── verdict_extensions.dart
└── backend/
    ├── app/
    │   ├── main.py              # FastAPI app
    │   ├── models.py            # SQLAlchemy models
    │   ├── schemas.py           # Pydantic schemas
    │   ├── db.py                # Database config
    │   ├── settings.py          # App settings
    │   ├── routers/             # API routes
    │   │   ├── checks.py
    │   │   ├── questions.py
    │   │   └── admin.py
    │   └── services/            # Business logic
    │       └── gemini_service.py
    ├── docker-compose.yml       # Docker services
    ├── Dockerfile              # Python container
    └── requirements.txt         # Python dependencies
\`\`\`

## 🎯 Features în Dezvoltare

### 🤖 AI Integration
- [ ] Gemini API key configuration
- [ ] Categorizare automată pentru conținut nou
- [ ] Fact-checking automat cu AI

### 📱 Frontend Enhancements
- [ ] Dropdown pentru filtrarea pe categorii
- [ ] Chips pentru selecție multiplă
- [ ] Loading states pentru API calls
- [ ] Error handling îmbunătățit

### 🔧 Backend Improvements
- [ ] Migrații database cu Alembic
- [ ] Authentication și authorization
- [ ] Rate limiting pentru API
- [ ] Logging avansat

## 🧪 Testing

### Backend
\`\`\`bash
cd backend
# Testează endpoint-urile
curl http://localhost:8000/fact-checks
curl http://localhost:8000/categories
curl "http://localhost:8000/fact-checks?category=health"
\`\`\`

### Frontend
\`\`\`bash
flutter test
\`\`\`

## 🔑 Environment Variables

Creează \`.env\` în directorul \`backend/\`:
\`\`\`env
DATABASE_URL=postgresql://user:password@localhost:5432/factcheck
REDIS_URL=redis://localhost:6379
GEMINI_API_KEY=your_gemini_api_key_here
\`\`\`

## 📊 Database Schema

### Tables
- **questions** - Întrebările utilizatorilor
- **checks** - Fact-check-urile cu verdictele
- **votes** - Sistemul de voting (viitor)

### Key Fields
- \`checks.category\` - Categoria fact-check-ului
- \`checks.verdict\` - true/false/mixed/unclear
- \`checks.confidence\` - Scor de încredere (0-100)

## 🤝 Contributing

1. Fork the project
2. Create feature branch (\`git checkout -b feature/AmazingFeature\`)
3. Commit changes (\`git commit -m 'Add AmazingFeature'\`)
4. Push to branch (\`git push origin feature/AmazingFeature\`)
5. Open Pull Request

## 📝 License

Distributed under the MIT License. See \`LICENSE\` for more information.

## 👨‍💻 Developer

Dezvoltat pentru licență - Aplicație completă de fact-checking pentru România.

---

**Ultimul update:** August 24, 2025  
**Versiune:** 1.0.0 - MVP Complete with Categories System
