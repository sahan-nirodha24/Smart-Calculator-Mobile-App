# 🚀 Smart Calculator - Premium Windows 11 Edition

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

A modern, high-performance, and visually stunning Calculator application built with Flutter. Inspired by the **Windows 11 Fluent Design System**, this app features a premium **Glassmorphism** UI, smooth motion effects, and a complete suite of productivity tools for both power users and everyday calculations.

---

## 📑 Table of Contents
- [✨ Key Features](#-key-features)
- [🎨 UI/UX Highlights](#-uiux-highlights)
- [🏗 Architecture & Folder Structure](#-architecture--folder-structure)
- [🛠 Tech Stack](#-tech-stack)
- [🚀 Getting Started](#-getting-started)
- [📸 Screenshots](#-screenshots)
- [⚙️ Advanced Settings](#-advanced-settings)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Key Features

### 🏠 Interactive Dashboard
*   **Central Hub**: A beautiful landing page with glass-style interactive cards for quick access to all modes.
*   **Visual Categories**: Neatly organized sections for Calculators and Conversion Tools.
*   **Intuitive Navigation**: Seamless sidebar integration for quick context switching without losing state.

### 📐 Advanced Calculation Modes
*   **Standard Calculator**: High-precision arithmetic with full memory support (MC, MR, M+, M-, MS) and real-time expression parsing.
*   **Scientific Suite**:
    *   **Advanced Trigonometry**: Comprehensive support for `sin`, `cos`, `tan`, and their inverses.
    *   **Hyperbolic Functions**: Dedicated `HYP` mode for `sinh`, `cosh`, and `tanh`.
    *   **Multi-Angle Support**: Toggle between **DEG**, **RAD**, and **GRAD** with immediate conversion.
    *   **Scientific Notation**: One-tap **F-E** toggle for fixed-to-exponential formatting.
*   **Graphing Calculator**: Real-time function plotting with interactive zoom and pan capabilities, powered by high-performance rendering.
*   **Programmer Suite**: Seamlessly convert between Binary, Octal, Decimal, and Hexadecimal with support for large integer calculations.

### 🔄 Smart Conversion Tools
*   **Unit Converter**: 10+ categories including Length, Weight, Speed, Temperature, and Data Storage.
*   **Currency Converter**: Live exchange rates for 160+ currencies with offline caching for reliable use without internet.

### 📅 Date & Age Tools
*   **Age Calculator**: Get your exact age in years, months, and days, including a "countdown to your next birthday."
*   **Date Difference**: Calculate the exact duration between two dates for project planning or event tracking.

---

## 🎨 Premium UI/UX Highlights

*   **Glassmorphism & Acrylic Effects**: A premium translucent UI with soft borders and vibrant "Electric Blue" gradients, utilizing `flutter_acrylic` for deep system integration.
*   **Fluent Motion Design**: 
    *   **Fade & Slide Navigation**: Ultra-smooth transitions between different calculator modes.
    *   **Tactile Feedback**: Interactive scale animations and **Haptic Feedback** (vibration) on every interaction for a premium feel.
*   **Enhanced Readability**: Large, bold typography using **Noto Sans** for high visibility and a professional, modern aesthetic.
*   **Adaptive & Responsive**: A clean layout that adapts seamlessly from a desktop sidebar to a mobile-friendly compact view.

---

## 🏗 Architecture & Folder Structure

The project follows a **Feature-First Architecture** combined with **Riverpod** for robust state management. This ensures scalability, testability, and clean code separation.

```text
lib/
├── core/               # Shared utilities, themes, and common widgets
│   ├── providers/      # App-wide state (Theme, Settings)
│   ├── theme/          # Fluent Design UI definitions
│   └── utils/          # Formatting and math helper functions
├── features/           # Modular functionality
│   ├── home/           # Dashboard and Navigation
│   ├── standard/       # Standard Calculator logic & UI
│   ├── scientific/     # Scientific Calculator engine
│   ├── currency/       # Real-time exchange rate logic
│   ├── ...             # Other independent modules
└── main.dart           # App entry and window configuration
```

---

## 🛠 Tech Stack

*   **Framework**: [Flutter](https://flutter.dev) (v3.x)
*   **State Management**: [Riverpod](https://riverpod.dev)
*   **UI Foundation**: [Fluent Design System](https://github.com/bdlukaa/fluent_ui)
*   **Typography**: [Google Fonts (Noto Sans)](https://pub.dev/packages/google_fonts)
*   **Math Engine**: [math_expressions](https://pub.dev/packages/math_expressions)
*   **Visuals**: [flutter_acrylic](https://pub.dev/packages/flutter_acrylic) & [window_manager](https://pub.dev/packages/window_manager)
*   **Charts**: [fl_chart](https://pub.dev/packages/fl_chart) for Graphing Calculator

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (Latest Stable)
*   Android Studio / VS Code
*   Active Internet Connection (for real-time currency updates)

### Quick Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/YOUR_GITHUB_USERNAME/smart_calculator.git
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    ```bash
    flutter run
    ```

---

## 📸 Screenshots

**Smart Calculator Home Page**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/2729fd4c-dbe8-43d6-85aa-9a44f5f85e5c" />

**Smart Calculator Side Navigation Bar**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/d98651df-1344-43b6-ad5c-0a0c1b95a86d" />

**Smart Calculator Standard Calculator Page**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/8fdf2b69-1e4b-4f45-a484-26a355f1f17b" />

**Smart Calculator Scientific Calculator Page**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/e5883ed3-3852-4272-ba7d-addd82a932ae" />

**Smart Calculator Graphing Calculator Page**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/a92ba19f-398d-4b9b-ac45-606a6190f8d7" />

**Smart Calculator Programmer Calculator Page**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/d51be9ed-8eab-4358-9510-e726a7effc9f" />

**Smart Calculator Date Calculation Page**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/f50698d7-e15f-4012-a5b0-5694d72d61ee" />

**Smart Calculator Currency Converter Page**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/2ac8484e-f981-42f4-9cb9-3b50be0fa18b" />

**Smart Calculator Unit Converter Page**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/ba1bc20e-3552-4919-a1d1-bcdb10d9217e" />

**Smart Calculator Settings Page**
<img width="1918" height="1019" alt="Image" src="https://github.com/user-attachments/assets/674fa508-91f8-40d0-98b9-46083ffbe0f5" />


---

## ⚙️ Advanced Settings
*   **Haptic Control**: Toggle tactile vibration feedback on or off.
*   **Precision Control**: Configure decimal places (2 to 5 digits) for all calculations.
*   **Theme Management**: Seamlessly switch between Light, Dark, or System themes.
*   **Unified History**: Clear all calculation logs across all modes with a single click.
*   **Reset to Defaults**: Restore all app settings to their original values instantly.

---

## 🤝 Contributing
Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request. 

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License
This project is licensed under the MIT License.

---
**Developed with ❤️ by [Sahan Nirodha](https://github.com/SahanNirodha)**
