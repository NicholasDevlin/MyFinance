# 📱 Flutter Backend Connection Guide

## 🚀 Backend Status
- **Backend URL**: http://localhost:3000
- **Swagger API Docs**: http://localhost:3000/api
- **Database**: MySQL on port 3307
- **Status**: ✅ Running in Docker

## 🔧 Connection Configuration

### For Android Emulator (Default)
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```
✅ **Already configured in your app**

### For iOS Simulator
```dart
static const String baseUrl = 'http://localhost:3000';
```

### For Physical Device Testing
Use your computer's IP address:
```dart
static const String baseUrl = 'http://192.168.1.104:3000'; // Main network
// OR
static const String baseUrl = 'http://192.168.10.104:3000'; // Secondary network
```

## 📋 Quick Test Steps

### 1. Test Backend Connection
```bash
curl http://localhost:3000/api
# Should return Swagger documentation
```

### 2. Test From Android Emulator
```bash
# From emulator terminal or adb shell
curl http://10.0.2.2:3000/api
```

### 3. Test Flutter App
1. **Android Emulator**: Use current config (`http://10.0.2.2:3000`)
2. **Physical Device**: Update to your IP (`http://192.168.1.104:3000`)

## 🛠️ Troubleshooting

### Connection Issues
- ✅ Backend is running: `docker-compose ps` in backend folder
- ✅ Port 3000 is open: `netstat -an | findstr 3000`
- ✅ IP address is correct for physical devices

### Authentication Issues
- Register a new user first through the app
- Check token is being saved in SharedPreferences
- Verify JWT token in API calls

### API Endpoint Issues
- Check Swagger docs: http://localhost:3000/api
- Verify endpoint URLs match backend routes
- Test endpoints directly in Swagger UI first

## 🎯 Ready to Test!

Your Flutter app is now configured to connect to your Docker backend:
- **✅ API Service**: Configured with proper base URL
- **✅ Authentication**: JWT token management ready
- **✅ Providers**: All state management providers set up
- **✅ Error Handling**: Token expiry and error handling included