# 🚀 Complete Startup Guide - Romanian Fact-Checking App

## 📋 Prerequisites
- Docker Desktop installed and running
- Flutter SDK installed (3.35.1+)
- Chrome browser (for web development)

## 🔧 STEP 1: Start Backend (Docker)

### Navigate to backend directory:
```bash
cd C:\Licenta\flutter_application_1\backend
```

### Check if containers are running:
```bash
docker-compose ps
```

### If containers are NOT running, start them:
```bash
docker-compose up -d
```

### If containers ARE running but need restart:
```bash
docker-compose restart
```

### Check logs if there are issues:
```bash
docker-compose logs api
docker-compose logs db
```

## 📊 STEP 2: Load Mock Data

### Once backend is running, add test data:
```bash
# Method 1: Using PowerShell
Invoke-RestMethod -Uri "http://localhost:8000/admin/seed-data" -Method Post

# Method 2: Using curl (if available)
curl -X POST http://localhost:8000/admin/seed-data

# Method 3: Open browser and go to API docs
# Navigate to: http://localhost:8000/docs
# Find "/admin/seed-data" endpoint and click "Try it out" -> "Execute"
```

### Verify data is loaded:
```bash
# Check fact-checks
Invoke-RestMethod -Uri "http://localhost:8000/fact-checks" -Method Get

# Check categories
Invoke-RestMethod -Uri "http://localhost:8000/categories" -Method Get
```

## 📱 STEP 3: Start Flutter Frontend

### Navigate to Flutter project root:
```bash
cd C:\Licenta\flutter_application_1
```

### Get dependencies (if first time or after pulling changes):
```bash
flutter pub get
```

### Start Flutter in Chrome:
```bash
flutter run -d chrome
```

### Alternative: Start with hot reload:
```bash
flutter run -d chrome --hot
```

## 🔍 STEP 4: Verify Everything Works

### Backend endpoints to test:
- API Documentation: http://localhost:8000/docs
- Fact-checks: http://localhost:8000/fact-checks
- Categories: http://localhost:8000/categories
- Specific fact-check: http://localhost:8000/checks/{id}

### Flutter app should show:
- List of fact-checks on homepage
- Category filtering (when implemented)
- Fact-check details page when clicking items
- Romanian content with proper verdicts

## 🛠️ Common Issues & Solutions

### Backend Issues:
```bash
# If containers fail to start:
docker-compose down
docker-compose up -d

# If database is empty:
# Re-run seed data command

# If port 8000 is busy:
# Check what's using the port and stop it
netstat -ano | findstr :8000

# Reset everything (nuclear option):
docker-compose down -v
docker-compose up -d
# Then re-run seed data
```

### Flutter Issues:
```bash
# If dependencies issues:
flutter clean
flutter pub get

# If Chrome not found:
flutter config --enable-web
flutter devices

# If hot reload not working:
# Stop with Ctrl+C and restart with flutter run -d chrome
```

## 📦 Quick Start Commands (Copy-Paste Ready)

### Complete startup from scratch:
```bash
# 1. Start backend
cd C:\Licenta\flutter_application_1\backend
docker-compose up -d

# 2. Wait 10 seconds, then load data
Start-Sleep 10
Invoke-RestMethod -Uri "http://localhost:8000/admin/seed-data" -Method Post

# 3. Start Flutter
cd ..
flutter run -d chrome
```

### Daily development startup (if already setup):
```bash
# 1. Quick backend start
cd C:\Licenta\flutter_application_1\backend
docker-compose start

# 2. Start Flutter
cd ..
flutter run -d chrome
```

## 🔄 Stopping Everything

### Stop Flutter:
```
# In Flutter terminal: press 'q' or Ctrl+C
```

### Stop Backend:
```bash
cd C:\Licenta\flutter_application_1\backend
docker-compose stop

# Or to remove containers completely:
docker-compose down
```

---

## 🎯 Expected Results

### When everything is working:
1. **Backend running on:** http://localhost:8000
2. **API docs available at:** http://localhost:8000/docs  
3. **Flutter running on:** http://localhost:XXXX (varies)
4. **Mock data loaded:** 5 Romanian fact-checks with categories
5. **Categories working:** 9 Romanian categories with icons

### Success indicators:
- ✅ Docker containers: api, db, redis, worker all running
- ✅ API responds with fact-checks data
- ✅ Flutter shows list of fact-checks
- ✅ Can click on fact-checks to see details
- ✅ No CORS errors in browser console

---

**Happy coding! 🚀**
