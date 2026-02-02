import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity information
///
/// Provides methods to check network connectivity status
/// and listen to connectivity changes.
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// Check if device is connected to internet
  ///
  /// Returns true by default if the check fails, so the app
  /// can attempt API calls and fall back to mock data gracefully.
  Future<bool> get isConnected async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      // If connectivity check fails, assume connected
      // so the app can attempt API calls and fall back gracefully
      return true;
    }
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }

  /// Get current connectivity type
  Future<ConnectivityType> get connectivityType async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _getConnectivityType(result);
    } catch (e) {
      return ConnectivityType.other;
    }
  }

  /// Convert ConnectivityResult to ConnectivityType
  ConnectivityType _getConnectivityType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectivityType.wifi;
      case ConnectivityResult.mobile:
        return ConnectivityType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectivityType.ethernet;
      case ConnectivityResult.none:
        return ConnectivityType.none;
      default:
        return ConnectivityType.other;
    }
  }
}

/// Connectivity type enum
enum ConnectivityType {
  none,
  wifi,
  mobile,
  ethernet,
  other,
}
