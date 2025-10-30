import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibelift/core/theme/app_colors.dart';
import 'package:vibelift/data/providers/health_provider.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthConnectScreen extends ConsumerStatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  ConsumerState<HealthConnectScreen> createState() =>
      _HealthConnectScreenState();
}

class _HealthConnectScreenState extends ConsumerState<HealthConnectScreen> {
  bool _isConnecting = false;
  bool _isConnected = false;
  String _statusMessage = 'Not connected to Health Connect / Samsung Health';
  AndroidDeviceInfo? androidInfo;
  bool _showPermissionButton = false;
  // Remove _permissionActionUrl field and _openHealthConnectPermissions function.

  @override
  void initState() {
    super.initState();
    _loadAndroidInfo();
    _checkConnection();
  }

  Future<void> _loadAndroidInfo() async {
    if (Platform.isAndroid) {
      try {
        androidInfo = await DeviceInfoPlugin().androidInfo;
        setState(() {});
      } catch (_) {
        androidInfo = null;
      }
    }
  }

  Future<void> _checkConnection() async {
    final healthService = ref.read(healthServiceProvider);
    final hasPermissions = await healthService.hasPermissions();

    if (mounted) {
      setState(() {
        _isConnected = hasPermissions;
        _statusMessage = hasPermissions
            ? 'Connected to Health Connect / Samsung Health'
            : 'Not connected to Health Connect / Samsung Health';
      });
    }
  }

  Future<void> _connectToHealth() async {
    setState(() {
      _isConnecting = true;
      _showPermissionButton = false;
      _statusMessage = 'Connecting to Health Connect / Samsung Health...';
    });
    try {
      final healthService = ref.read(healthServiceProvider);
      bool authorized = false;
      String permissionError = '';
      bool showPermissionButton = false;
      try {
        authorized = await healthService.requestAuthorization();
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('permission') ||
            errStr.contains('securityexception')) {
          permissionError =
              'Missing Health Connect permissions. Open Health Connect settings and grant all permissions for VibeLift.';
          showPermissionButton = true;
        } else if (errStr.contains('healthconnectexception')) {
          permissionError =
              'Health Connect app missing or misconfigured. Update Google Play Store and Health Connect.';
          showPermissionButton = true;
        } else {
          permissionError = 'Unknown error: ${e.toString()}';
        }
      }
      if (!authorized) {
        final shealthStatus = await healthService.getSamsungHealthStatus();
        final isModernAndroid =
            Platform.isAndroid && (androidInfo?.version.sdkInt ?? 0) >= 33;
        setState(() {
          _isConnecting = false;
          _isConnected = false;
          _statusMessage = permissionError.isNotEmpty
              ? permissionError
              : isModernAndroid
                  ? 'You need to grant Health Connect permissions. Open Health Connect > App permissions > VibeLift > Enable all.'
                  : shealthStatus['installed'] == false
                      ? 'Samsung Health is not installed. Please install from the Play Store.'
                      : shealthStatus['enabled'] == false
                          ? 'Samsung Health is installed but disabled. Enable it in settings.'
                          : (shealthStatus['version'] as int) < 700000000
                              ? 'Samsung Health installed but outdated. Update from Play Store.'
                              : 'Authorization failed.';
          // Show the permission button if needed
          _showPermissionButton = showPermissionButton ||
              (permissionError.isEmpty && isModernAndroid);
        });
        return;
      }
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = authorized;
          _statusMessage = 'Successfully connected! Syncing health data...';
        });
        if (authorized) {
          await healthService.syncHealthData();
          ref.invalidate(todayStepsProvider);
          ref.invalidate(todayCaloriesProvider);
          ref.invalidate(latestHealthWeightProvider);
          ref.invalidate(todayWorkoutsProvider);
          setState(() {
            _statusMessage = 'Health data synced successfully!';
          });
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = false;
          _statusMessage = 'Unknown error: ${err.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Health Connect'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isConnected
                        ? AppColors.lightPrimary.withAlpha(25)
                        : AppColors.lightTextSecondary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isConnected
                        ? CupertinoIcons.checkmark_shield_fill
                        : CupertinoIcons.heart_fill,
                    size: 80,
                    color: _isConnected
                        ? AppColors.lightPrimary
                        : AppColors.lightTextSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  _isConnected ? 'Connected' : 'Connect Health Data',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Status message
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (_showPermissionButton && !_isConnected)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('Open Health Connect Settings'),
                        onPressed: () async {
                          final uris = [
                            Uri.parse(
                                'content://com.google.android.apps.healthdata/settings/app_permissions'),
                            Uri.parse(
                                'package:com.google.android.apps.healthdata'),
                          ];
                          for (final uri in uris) {
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                              return;
                            }
                          }
                          final settingsUri = Uri.parse(
                              'android.settings.APPLICATION_DETAILS_SETTINGS');
                          if (await canLaunchUrl(settingsUri)) {
                            await launchUrl(settingsUri);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                          'Then tap App permissions > VibeLift > Allow all.',
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),

                const SizedBox(height: 40),

                // Features list
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Features',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          CupertinoIcons.flame_fill,
                          'Track daily steps and calories',
                        ),
                        _buildFeatureItem(
                          CupertinoIcons.chart_bar_fill,
                          'Sync weight progress',
                        ),
                        _buildFeatureItem(
                          CupertinoIcons.heart_fill,
                          'Monitor workout sessions',
                        ),
                        _buildFeatureItem(
                          CupertinoIcons.clock_fill,
                          'Real-time health data updates',
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Connect button
                if (!_isConnected)
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isConnecting ? null : _connectToHealth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isConnecting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Connect to Health App',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                if (_isConnected)
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.lightPrimary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Info text
                Text(
                  'This app uses Health Connect / Samsung Health to sync your fitness data. Your data is stored securely on your device.',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary.withAlpha(179),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.lightPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
