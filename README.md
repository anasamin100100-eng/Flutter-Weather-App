# 🌤️ Flutter Weather App

A Flutter-based weather application that provides real-time weather information using the **WeatherAPI**. The app automatically detects the user's current location using GPS and displays weather conditions for that location.

Users can also search for weather information by city name and explore hourly, weekly, and historical weather forecasts.

## ✨ Features

- **GPS-Based Location Detection:** Automatically detects the user's current city and country.
- **Real-Time Weather:** Displays current temperature and weather conditions.
- **City Search:** Search for weather information in different cities around the world.
- **Hourly Forecast:** View upcoming hourly weather updates.
- **7-Day Forecast:** Check weather predictions for the next seven days.
- **Past 7-Day Weather:** View historical weather information.
- **Dark & Light Themes:** Switch between dark and light modes.
- **Responsive UI:** Clean and user-friendly interface.

## 🛠️ Technologies Used

- Flutter
- Dart
- WeatherAPI
- Riverpod (State Management)
- HTTP Package (API Integration)
- Geolocator (GPS Location)
- Flutter Dotenv (Environment Variables)
- Intl (Date Formatting)

## 📸 Screenshots

<!-- Add your application screenshots here -->

| Home Screen | Hourly Forecast | Weekly Forecast |
|---|---|---|
| <img width="608" height="1280" alt="image" src="https://github.com/user-attachments/assets/97de908e-16d8-4a20-ac45-2447cad64e46" /> | <img width="720" height="422" alt="image" src="https://github.com/user-attachments/assets/3de278bb-76a3-49a0-ac8a-7a69d00ffe8b" /> <img width="720" height="420" alt="image" src="https://github.com/user-attachments/assets/ca339fa9-7f43-4fa1-95c0-df2d47bb3d26" /> <img width="718" height="426" alt="image" src="https://github.com/user-attachments/assets/1489abfd-df11-4832-a490-2dc6686352ea" /> <img width="718" height="422" alt="image" src="https://github.com/user-attachments/assets/5c59085c-e6f9-4edf-bb5e-147042cb3d3c" /> <img width="714" height="424" alt="image" src="https://github.com/user-attachments/assets/1b0d8f92-224e-4e7c-9e85-4f6504bc2ad8" />| <img width="612" height="1280" alt="image" src="https://github.com/user-attachments/assets/67385dce-edbc-46a2-a7d0-acae875562b1" /> <img width="603" height="1280" alt="image" src="https://github.com/user-attachments/assets/d3fe4504-acbd-4896-a8ba-f9b05d86ea7a" /> |

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/anasamin100100-eng/Flutter-Weather-App.git
```

### 2. Navigate to the Project

```bash
cd Flutter-Weather-App
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Environment Variables

Create a `.env` file in the root directory of the project:

```env
WEATHER_API_KEY=your_weatherapi_key
```

Get your API key from [WeatherAPI](https://www.weatherapi.com/).

**Note:** The `.env` file is excluded from GitHub. You must create your own file and provide a valid API key before running the application.

### 5. Run the Application

```bash
flutter run
```

## 📁 Project Structure

```text
lib/
├── Provider/
│   └── theme_provider.dart
├── Service/
│   └── api_service.dart
├── Theme/
│   └── theme.dart
├── View/
│   ├── home_screen.dart
│   ├── splash_screen.dart
│   └── weekly_forecast.dart
└── main.dart

assets/
.env.example
.gitignore
pubspec.yaml
```

*Folder and file names may vary depending on the final project structure.*

## 📍 Location Permissions

The application uses the device's GPS location to identify the user's current city.

- Enable location services on your device.
- Grant location permission when prompted.
- If location permission is denied or GPS is unavailable, the application uses Karachi, Pakistan as the fallback location.

## 🔑 API

Weather information is retrieved from [WeatherAPI](https://www.weatherapi.com/).

The application uses weather forecast and historical weather endpoints.

## 👨‍💻 Developer

**Muhammad Anas Amin**

- GitHub: [anasamin100100-eng](https://github.com/anasamin100100-eng)
- LinkedIn: [Muhammad Anas Amin](https://www.linkedin.com/in/muhammad-anas-muhammad-amin-94b3163b/)

---

⭐ If you find this project useful, consider giving it a star!
