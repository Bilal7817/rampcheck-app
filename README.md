# RampCheck - Aircraft Maintenance Support App

Cross-platform maintenance inspection system for aircraft technicians.

## Features
- Offline-first architecture
- Cross-platform (macOS, Android, iOS)
- Secure synchronization with backend API
- GDPR-compliant data handling

## Tech Stack
- **Frontend:** Flutter/Dart
- **Backend:** Flask/Python
- **Database:** SQLite (local & remote)

## Project Structure
```
rampcheck_app/
├── backend/              # Flask API
├── rampcheck_flutter/    # Flutter application
└── README.md
```

## Development
- Main branch: Stable releases
- Dev branch: Active development

## Setup Instructions

### Backend
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python init_db.py
python app.py
```

### Flutter App
```bash
cd rampcheck_flutter
flutter pub get
flutter run
```