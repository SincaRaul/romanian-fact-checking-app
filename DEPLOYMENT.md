# 🚀 Deployment Instructions

## 📋 Pre-deployment Checklist

### 🔑 Environment Setup
- [ ] Obține Gemini API key de la Google
- [ ] Configurează `.env` file în backend
- [ ] Actualizează CORS origins pentru producție
- [ ] Configurează database production URL

### 🐳 Docker Production
```bash
# Build production images
docker-compose -f docker-compose.prod.yml build

# Deploy with production settings
docker-compose -f docker-compose.prod.yml up -d
```

### 🌐 Frontend Deployment
```bash
# Build pentru web
flutter build web

# Deploy la hosting provider (Netlify, Vercel, Firebase)
# Configurează API_BASE_URL pentru producție
```

### 📊 Database Migration
```bash
# Pentru producție, folosește Alembic pentru migrații
pip install alembic
alembic init alembic
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

## 🔧 Configuration Files Needed

### 1. `.env` (backend)
```env
DATABASE_URL=postgresql://user:password@db:5432/factcheck
REDIS_URL=redis://redis:6379
GEMINI_API_KEY=your_production_gemini_key
CORS_ORIGINS=https://your-frontend-domain.com
```

### 2. `docker-compose.prod.yml`
- Use production database
- Configure proper volumes
- Set environment variables
- Enable SSL/TLS

### 3. Flutter `lib/config/api_config.dart`
```dart
class ApiConfig {
  static const String baseUrl = 
    String.fromEnvironment('API_BASE_URL', 
      defaultValue: 'https://your-api-domain.com');
}
```

## 📈 Monitoring & Maintenance

### Logs
```bash
# Backend logs
docker-compose logs api

# Database logs  
docker-compose logs db
```

### Health Checks
- API: `GET /health`
- Database: Check connection status
- Redis: Check cache functionality

### Backup Strategy
- Daily database backups
- Code repository backups
- Docker volume backups

## 🔄 CI/CD Pipeline Ideas

### GitHub Actions
- Automated testing on PR
- Docker image building
- Deployment to staging/production
- Database migration automation

### Testing Pipeline
- Flutter widget tests
- API endpoint tests
- Integration tests
- Performance tests

---
**Note:** Acest fișier va fi actualizat pe măsură ce implementăm deployment-ul real.
