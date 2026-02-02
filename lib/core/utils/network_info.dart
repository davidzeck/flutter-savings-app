import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity information
///
/// Provides methods to check network connectivity status
/// and listen to connectivity changes.
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// Check if device is connected to internet
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnected);
  }

  /// Check if connectivity result indicates connection
  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  /// Get current connectivity type
  Future<ConnectivityType> get connectivityType async {
    final result = await _connectivity.checkConnectivity();
    return _getConnectivityType(result);
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
