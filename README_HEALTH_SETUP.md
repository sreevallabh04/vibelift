# Samsung Health / Health Connect Integration Setup

This app integrates with Samsung Health (Android) and Apple Health (iOS) to sync real fitness data.

## Features
- ✅ Steps tracking
- ✅ Calories burned tracking
- ✅ Weight tracking and history
- ✅ Workout sessions
- ✅ Real-time data sync

## Android Setup (Samsung Health / Health Connect)

### 1. Prerequisites
- Samsung Health app installed and updated to the latest version
- Android device with API level 26 or higher

### 2. Permissions
The app requests the following permissions:
- Read/Write Steps
- Read/Write Weight
- Read/Write Active Calories Burned
- Read/Write Exercise/Workout data

### 3. First Time Setup
1. Open the VibeLift app
2. Tap the heart icon (❤️) in the dashboard header
3. Tap "Connect to Health App"
4. Grant the requested permissions in Samsung Health/Health Connect
5. Data will sync automatically

### 4. Troubleshooting

#### Error: "OLD_VERSION_PLATFORM"
- This means Samsung Health needs to be updated
- Go to Play Store → Samsung Health → Update

#### Error: "Connection Failed"
- Ensure Samsung Health is installed
- Check that location permissions are granted
- Restart the app and try again

#### No Data Showing
- Open Samsung Health and ensure data is being tracked
- Grant all requested permissions
- Pull to refresh the dashboard
- Tap the heart icon to resync

## iOS Setup (Apple Health)

### 1. Prerequisites
- iOS 14 or higher
- Apple Health app (pre-installed on iOS)

### 2. Permissions
The app will request permission to read/write:
- Steps
- Active Energy (Calories)
- Body Mass (Weight)
- Workouts

### 3. First Time Setup
1. Open the VibeLift app
2. Tap the heart icon (❤️) in the dashboard header
3. Tap "Connect to Health App"
4. Grant permissions in the Apple Health popup
5. Data will sync automatically

## Data Privacy
- All health data is stored locally on your device
- The app does NOT send your health data to any external servers
- Health data is only accessed when you explicitly connect the health app
- You can revoke permissions anytime from your device's health app settings

## Syncing Data

### Automatic Sync
- The app automatically syncs data when you open it
- Pull to refresh on the dashboard to manually sync

### Manual Sync
1. Tap the heart icon (❤️) in the dashboard
2. The app will fetch the latest data from your health app

## Supported Data Types

| Data Type | Samsung Health | Apple Health |
|-----------|---------------|--------------|
| Steps | ✅ | ✅ |
| Calories | ✅ | ✅ |
| Weight | ✅ | ✅ |
| Workouts | ✅ | ✅ |
| Heart Rate | ⏳ Coming Soon | ⏳ Coming Soon |
| Sleep | ⏳ Coming Soon | ⏳ Coming Soon |

## Technical Details

### Packages Used
- `health: ^13.1.3` - For accessing health data
- `permission_handler: ^12.0.1` - For managing permissions

### Architecture
```
lib/data/services/health_service.dart - Health data service
lib/data/providers/health_provider.dart - Riverpod providers
lib/screens/health_connect/ - Health connection UI
```

## Need Help?
If you encounter any issues:
1. Check that your health app is updated
2. Ensure all permissions are granted
3. Restart the app
4. Check the troubleshooting section above

