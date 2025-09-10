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


Distributed under the MIT License. See \`LICENSE\` for more information.

## 👨‍💻 Developer

Dezvoltat pentru licență - Aplicație completă de fact-checking pentru România.

---

**Ultimul update:** 10 Septembrie, 2025  
**Versiune:** 1.0.0 - MVP Complete with Categories System
