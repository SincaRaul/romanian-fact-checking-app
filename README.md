# CheckIT - Romanian Fact-Checking Application

Romanian fact-checking platform built with Flutter frontend and FastAPI backend.

## Requirements

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Flutter SDK 3.35.1+
- Chrome browser

## Installation

### 1. Install Docker

**Windows:**
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop/
2. Run installer and restart computer
3. Open Docker Desktop and wait for it to start

**Mac:**
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop/
2. Drag to Applications folder and start

**Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
```

Verify Docker is working:
```bash
docker --version
docker-compose --version
```

### 2. Install Flutter

Download Flutter SDK from https://flutter.dev/docs/get-started/install
Add Flutter to your PATH.

Verify Flutter:
```bash
flutter doctor
```

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

Wait for services to start (30-60 seconds), then verify:
```bash
docker-compose ps
```

Backend will be available at: `http://localhost:8000`

### 3. Initialize Database

```bash
curl -X POST http://localhost:8000/admin/seed-data
```

If curl is not available on Windows, open in browser:
`http://localhost:8000/admin/seed-data`

### 4. Start Frontend

```bash
cd ..
flutter pub get
flutter run -d chrome
```

Frontend will open at: `http://localhost:3000`

## Troubleshooting

### Docker Issues
- **"docker-compose not recognized"**: Install Docker Desktop
- **"Cannot connect to Docker daemon"**: Start Docker Desktop application
- **Ports already in use**: Run `docker-compose down` first

### Flutter Issues
- **"flutter not recognized"**: Add Flutter to system PATH
- **Chrome not found**: Install Chrome browser
- **Dependencies error**: Run `flutter clean && flutter pub get`

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

### Stop Services
```bash
cd backend
docker-compose down
```

## Configuration

Backend configuration in `backend/app/settings.py`:
- Database URL
- Redis URL  
- API Keys

Frontend API endpoint in `lib/services/api_service.dart`.

API Documentation: `http://localhost:8000/docs`

## License

Distributed under the MIT License.

## Developer

Dezvoltat pentru licență - Aplicație completă de fact-checking pentru România.

---

**Version:** 1.0.0 - MVP Complete with Categories System