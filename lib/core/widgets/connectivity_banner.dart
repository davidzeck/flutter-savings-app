import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../di/service_locator.dart';
import '../utils/network_info.dart';

/// Global connectivity banner that shows when the device is offline
///
/// Wraps a child widget and displays a persistent banner at the top
/// when the device loses network connectivity.
class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late final NetworkInfo _networkInfo;
  late final AnimationController _animController;
  late final Animation<double> _slideAnimation;
  StreamSubscription<bool>? _connectivitySub;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _networkInfo = getIt<NetworkInfo>();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animationNormal),
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _checkInitialConnectivity();
    _listenToConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final connected = await _networkInfo.isConnected;
    if (!connected && mounted) {
      setState(() => _isOffline = true);
      _animController.forward();
    }
  }

  void _listenToConnectivity() {
    _connectivitySub = _networkInfo.onConnectivityChanged.listen((connected) {
      if (!mounted) return;
      setState(() => _isOffline = !connected);
      if (_isOffline) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated offline banner
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            if (!_isOffline && _animController.isDismissed) {
              return const SizedBox.shrink();
            }
            return FractionalTranslation(
              translation: Offset(0, _slideAnimation.value),
              child: child,
            );
          },
          child: Material(
            color: AppColors.error,
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: AppDimensions.sm),
                    Text(
                      AppStrings.noInternetConnection,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Main content
        Expanded(child: widget.child),
      ],
    );
  }
}
