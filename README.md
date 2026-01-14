# Rosella - PCOS Detection & Management App

A comprehensive mobile health application built with Flutter and Firebase that leverages Machine Learning and Deep Learning to predict and detect Polycystic Ovary Syndrome (PCOS) in women.

## Demo

<div align="center">
  
[https://github.com/user-attachments/assets/your-video-id.mp4](https://github.com/user-attachments/assets/1e3dd312-aeaa-43bf-9844-350f191de810)

</div>

## About The Project

Rosella is an intelligent healthcare application designed to assist in early detection and management of PCOS through dual prediction mechanisms. The app combines symptom-based ML prediction with ultrasound image analysis using deep learning, providing a comprehensive diagnostic support tool.

## Features

- **Dual PCOS Detection System**
  - ML-based prediction using clinical parameters and symptoms
  - DL-based ultrasound image analysis for PCOS detection
- **User Authentication** - Secure login and signup using Firebase Authentication
- **Real-time Database** - User data management with Firebase Firestore
- **Health Tracking** - Monitor symptoms and health metrics over time
- **User-Friendly Interface** - Intuitive design for seamless user experience
- **Personalized Results** - Detailed prediction reports and recommendations

## Built With

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **Machine Learning:** 
  - ML Model - Symptom-based PCOS prediction
  - DL Model - Ultrasound image classification using CNN
- **Platforms:** Android & iOS


## Prerequisites

Before running this project, ensure you have:

- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Firebase CLI
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

## Getting Started

### Installation

**1. Clone the repository**

    git clone https://github.com/yourusername/rosella.git
    cd rosella

**2. Install dependencies**

    flutter pub get

**3. Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS app to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place the files in their respective directories

**4. Run the app**

    flutter run

## ML/DL Models

### Model 1: PCOS Prediction (ML)
- **Type:** Classification model using traditional ML algorithms
- **Input:** Clinical parameters (age, BMI, menstrual cycle irregularity, hormone levels, etc.)
- **Output:** PCOS probability score and risk assessment

### Model 2: Ultrasound Image Analysis (DL)
- **Type:** Convolutional Neural Network (CNN)
- **Input:** Uterus/ovarian ultrasound images
- **Output:** PCOS presence detection with confidence score
- **Accuracy:** Optimized for medical image classification

## Project Structure

    lib/
    ├── models/          # ML/DL model integration
    ├── screens/         # App screens and UI
    ├── services/        # Firebase and API services
    ├── widgets/         # Reusable UI components
    ├── utils/           # Helper functions and constants
    └── main.dart        # App entry point

## Use Cases

- Early PCOS screening for at-risk women
- Supplementary diagnostic tool for healthcare providers
- Health monitoring and symptom tracking
- Educational resource about PCOS

## Disclaimer

This application is designed as a supportive tool and should not replace professional medical diagnosis. Always consult with qualified healthcare professionals for accurate diagnosis and treatment of PCOS.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

