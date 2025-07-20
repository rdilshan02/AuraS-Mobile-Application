# AuraS Skincare App

A cross-platform Flutter application for smart skincare management, featuring AI-powered skin analysis, dermatologist appointment booking, and a 24/7 AI chatbot assistant. The app integrates with Firebase for authentication, data storage, and cloud functions.

## Features

- **AI Skin Analysis**: Upload a photo and receive instant AI-powered skin analysis with personalized care recommendations.
- **Doctor Channelling**: Book appointments with certified dermatologists, view your upcoming appointments, and receive confirmations.
- **AI Chatbot**: Get real-time answers to skincare questions from an intelligent chatbot.
- **Blog & FAQ**: Access the latest skincare tips, articles, and frequently asked questions.
- **User Authentication**: Secure sign up, login, and email verification using Firebase Auth.
- **Admin Panel**: (For admins) Manage dermatologist profiles and appointments.
- **Push Notifications & Email**: Receive appointment confirmations and reminders (via Firebase Cloud Functions and email integration).


## Project Structure

```
lib/
  ├── main.dart                # App entry point
  ├── home_page.dart           # Main dashboard with feature navigation
  ├── AIAnalysisScreen.dart    # AI skin analysis feature
  ├── Ai_results.dart          # AI analysis result display
  ├── BookAppointment.dart     # Appointment booking UI
  ├── AppointmentScreen.dart   # View user's appointments
  ├── DoctorChannelingScreen.dart # List and channel dermatologists
  ├── ChatBotScreen.dart       # AI chatbot interface
  ├── BlogScreen.dart          # Skincare blog articles
  ├── FAQScreen.dart           # Frequently asked questions
  ├── AboutUsScreen.dart       # About the app/team
  ├── user authentication/     # Auth, signup, login, verification
  ├── services/                # AI and backend service integrations
  ├── config/                  # Firebase config
  └── shared_widgets.dart      # Reusable UI components
functions/                     # Firebase Cloud Functions (Node.js)
assets/images/                 # App images and icons
```

## Tech Stack
- **Flutter** (Dart)
- **Firebase** (Auth, Firestore, Storage, Functions)
- **Google Generative AI** (for skin analysis and chatbot)
- **Node.js** (Cloud Functions for notifications, email, WhatsApp)

## Getting Started

### Prerequisites
- Flutter SDK (3.0+ recommended)
- Firebase project (see below)
- Android Studio/Xcode/VS Code for development

### Setup
1. **Clone the repository:**
   ```sh
   git clone <repo-url>
   cd AuraS-Mobile-Application
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Firebase setup:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
   - Update `lib/config/firebase_config.dart` and `lib/user authentication/firebase_options.dart` if needed.
   - Enable Email/Password Auth and Firestore in the Firebase Console.
4. **Run the app:**
   ```sh
   flutter run
   ```

### Cloud Functions (Optional)
- Navigate to the `functions/` directory and install dependencies:
  ```sh
  cd functions
  npm install
  ```
- Deploy functions to Firebase:
  ```sh
  firebase deploy --only functions
  ```

## Usage
- **Sign up** with your email and verify it.
- **Analyze your skin** using the AI feature.
- **Book appointments** with dermatologists.
- **Chat** with the AI assistant for skincare advice.
- **Read blogs** and FAQs for more information.


## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](LICENSE)
