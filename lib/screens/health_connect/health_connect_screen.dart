import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibelift/core/theme/app_colors.dart';
import 'package:vibelift/data/providers/health_provider.dart';

class HealthConnectScreen extends ConsumerStatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  ConsumerState<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends ConsumerState<HealthConnectScreen> {
  bool _isConnecting = false;
  bool _isConnected = false;
  String _statusMessage = 'Not connected to Health Connect / Samsung Health';

  @override
  void initState() {
    super.initState();
    _checkConnection();
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
      _statusMessage = 'Connecting to Health Connect / Samsung Health...';
    });

    try {
      final healthService = ref.read(healthServiceProvider);
      final authorized = await healthService.requestAuthorization();

      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = authorized;
          _statusMessage = authorized
              ? 'Successfully connected! Syncing health data...'
              : 'Connection failed. Please check your Samsung Health app is updated.';
        });

        if (authorized) {
          // Sync health data
          await healthService.syncHealthData();
          
          // Refresh providers
          ref.invalidate(todayStepsProvider);
          ref.invalidate(todayCaloriesProvider);
          ref.invalidate(latestHealthWeightProvider);
          ref.invalidate(todayWorkoutsProvider);

          setState(() {
            _statusMessage = 'Health data synced successfully!';
          });

          // Navigate back after successful connection
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = false;
          _statusMessage = 'Error: ${error.toString()}';
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
                      side: const BorderSide(color: AppColors.lightPrimary, width: 2),
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

