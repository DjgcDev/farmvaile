# 🌾 FarmvAIle
### AI-Assisted Mobile Application for Agricultural Farmers

A professional Flutter mobile application built for CS 302, featuring AI-powered agricultural recommendations, weather-based farming guidance, crop planning, and real-time market prices.

---

## 📱 App Features

### 🏠 Home Dashboard
- Personalized greeting with weather summary
- AI-powered planting recommendation banner
- Quick action navigation cards
- Live market price snapshot
- Crop recommendation carousel
- Daily farming tip

### 🌤️ Weather & Climate
- Current temperature, humidity, wind speed
- 7-day forecast with farming icons
- Weather-based farming alerts (rain, UV, wind)
- AI-generated planting calendar windows

### 🌿 Crop Planner
- Category filtering (Grains, Vegetables, Fruits)
- Detailed crop cards with income estimates
- Full crop detail screen with:
  - Growth period & water needs
  - Suitable regions
  - Expert AI farming tips (numbered)
  - Add to My Farm / Bookmark actions

### 📈 Market Prices (3 Tabs)
- **Live Prices**: Real-time farm gate prices with trend indicators
- **Income Estimator**: Interactive calculator with crop selector & land area slider
- **Trends**: 30-day price trend bars with AI market forecast

### 🤖 AI Chatbot (FarmBot)
- Conversational AI farming assistant
- Quick reply chips for common questions
- Contextual responses for:
  - Rice/crop-specific tips
  - Pest & disease management
  - Harvest timing
  - Market price analysis
  - Soil preparation
  - General crop recommendations

### 👤 Farm Profile
- Farmer profile with farm stats
- Farm details (region, soil type, water source, crops)
- Notification toggles (weather, market, planting, pest)
- App settings (language, help, about)

---

## 🎨 Design System

| Element | Value |
|---|---|
| Primary Green | `#2E7D32` |
| Light Green | `#4CAF50` |
| Soft Green | `#81C784` |
| Pale Green | `#E8F5E9` |
| Accent Amber | `#FFA000` |
| Soil Brown | `#5D4037` |
| Sky Blue | `#0288D1` |
| Font | Georgia (serif — warm, trustworthy) |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code with Flutter plugin
- Android Emulator or iOS Simulator (or physical device)

### Installation

```bash
# 1. Navigate to project
cd farmvaile

# 2. Install dependencies
flutter pub get

# 3. Run on device/emulator
flutter run

# 4. Build APK (Android)
flutter build apk --release

# 5. Build App Bundle (Play Store)
flutter build appbundle --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry + bottom navigation shell
├── theme/
│   └── app_theme.dart           # Colors, typography, component themes
├── models/
│   └── models.dart              # Crop, Weather, Market, Chat data models + sample data
├── widgets/
│   └── common_widgets.dart      # Reusable: SectionHeader, StatCard, TagChip, GreenButton
└── screens/
    ├── home_screen.dart         # Dashboard
    ├── weather_screen.dart      # Weather & climate
    ├── crops_screen.dart        # Crop planner + detail screen
    ├── market_screen.dart       # Market prices + income estimator
    ├── chat_screen.dart         # AI chatbot
    └── profile_screen.dart      # Farmer profile & settings
```

---

## 🔌 Future API Integration Points

Replace sample data in `lib/models/models.dart` with real API calls:

| Feature | Suggested API |
|---|---|
| Weather | OpenWeatherMap API / PAGASA |
| Market Prices | DA (Department of Agriculture) API |
| AI Chatbot | Anthropic Claude API / OpenAI GPT |
| Location | Google Maps / Geolocator package |
| Push Notifications | Firebase Cloud Messaging |

---

## 👥 CS 302 Team
- Catli, Don
- Condez, Charles  
- Fajarillo, J Louisse

---

*FarmvAIle — Empowering Filipino Farmers with AI* 🇵🇭
