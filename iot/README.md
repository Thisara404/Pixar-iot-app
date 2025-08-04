# Innovior LED Control App

A Flutter mobile application to control an LED connected to a NodeMCU (ESP8266) microcontroller via REST API.

## Features

- **Real-time LED Control**: Turn LED ON/OFF remotely
- **Status Monitoring**: Check current LED state
- **Connection Management**: Configure NodeMCU IP address
- **Visual Feedback**: Animated LED indicator
- **Error Handling**: Robust network error management

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- NodeMCU with LED circuit
- Both devices on the same WiFi network

### Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure NodeMCU IP:**
   - Upload the NodeMCU code to your device
   - Note the IP address from Serial Monitor
   - Update the IP in the Flutter app settings

3. **Run the app:**
   ```bash
   flutter run
   ```

### NodeMCU API Endpoints

- `GET /status` - Get LED state
- `GET /led/on` - Turn LED ON
- `GET /led/off` - Turn LED OFF

### Usage

1. **Connect to NodeMCU:**
   - Tap the settings icon in the app bar
   - Enter your NodeMCU's IP address
   - Tap "Connect"

2. **Control LED:**
   - Use "Turn ON" and "Turn OFF" buttons
   - Check status with "Check Status" button
   - Monitor connection status at the top

### Troubleshooting

- **Connection Issues:** Ensure both devices are on the same WiFi network
- **IP Address:** Verify the NodeMCU IP address in Serial Monitor
- **Network:** Check firewall settings if connection fails

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   └── led_state.dart     # LED state data model
├── screens/
│   └── home_screen.dart   # Main UI screen
└── services/
    └── api_service.dart   # HTTP client service
```

## Dependencies

- `http: ^1.2.2` - HTTP client for API calls
- `cupertino_icons: ^1.0.2` - iOS-style icons

---

**Innovior IoT Task 02** - Building Flutter IoT Mobile App with NodeMCU Integration
