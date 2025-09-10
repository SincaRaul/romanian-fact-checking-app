# CheckIT - Romanian Fact-Checking Application

Romanian fact-checking platform built with Flutter frontend and FastAPI backend.

## Requirements

- Docker and Docker Compose
- Flutter SDK 3.35.1+
- Chrome browser

## Quick Start

### 1. Clone Repository

```bash
git clone <repository-url>
cd flutter_application_1
```

### 2. Start Backend

```bash
cd backend
docker-compose up -d
```

Verify services are running:
```bash
docker-compose ps
```

Backend will be available at: `http://localhost:8000`
API Documentation: `http://localhost:8000/docs`

### 3. Initialize Database (First Time Only)

```bash
curl -X POST http://localhost:8000/admin/seed-data
```

### 4. Start Frontend

```bash
cd ..
flutter pub get
flutter run -d chrome
```

Frontend will open in Chrome at: `http://localhost:3000`

## Architecture

- **Frontend**: Flutter with Riverpod state management
- **Backend**: FastAPI with PostgreSQL and Redis
- **AI**: Google Gemini integration for fact-checking
- **Analytics**: HyperLogLog for unique user tracking

## API Endpoints

- `GET /checks` - List fact-checks
- `GET /checks/{id}` - Get specific fact-check
- `POST /questions` - Submit new question
- `GET /categories` - Available categories

## Development

### Backend Only
```bash
cd backend
docker-compose up
```

### Frontend Only
```bash
flutter pub get
flutter run -d chrome
```

### Reset Database
```bash
curl -X POST http://localhost:8000/admin/seed-data
```

## Configuration

Backend configuration in `backend/app/settings.py`:
- Database URL
- Redis URL  
- API Keys

Frontend API endpoint in `lib/services/api_service.dart`.

## Categories

- Football
- Internal Politics
- External Politics
- Bills & Utilities
- Health
- Technology
- Environment
- Economy
- Other

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
