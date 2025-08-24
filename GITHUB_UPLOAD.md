# 🚀 GitHub Upload Commands

## După ce creezi repository pe GitHub.com, rulează:

```bash
cd C:\Licenta\flutter_application_1

# Adaugă remote origin (înlocuiește USERNAME cu numele tău GitHub)
git remote add origin https://github.com/USERNAME/romanian-fact-checking-app.git

# Verifică că remote-ul este configurat
git remote -v

# Push la GitHub
git branch -M main
git push -u origin main
```

## Verificare finală:
```bash
# Verifică că totul a fost încărcat
git log --oneline -5
git status
```

## Alternative cu SSH (dacă ai configurat SSH keys):
```bash
git remote add origin git@github.com:USERNAME/romanian-fact-checking-app.git
git push -u origin main
```

---
**Notă:** Înlocuiește `USERNAME` cu numele tău real de GitHub!
