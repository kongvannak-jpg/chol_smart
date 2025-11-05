import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import '../config/network_config.dart';

class NetworkSecurityService {
  // Use configuration from NetworkConfig class
  static List<String> get _allowedWiFiNames => NetworkConfig.allowedWiFiNames;
  static List<String> get _allowedIpRanges => NetworkConfig.allowedIpRanges;
  static String get _companyPublicIp => NetworkConfig.companyPublicIp;

  /// Check if the device is connected to an allowed network
  static Future<NetworkSecurityResult> checkNetworkSecurity() async {
    try {
      // Check connectivity type
      final ConnectivityResult connectivityResult = await Connectivity()
          .checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        return NetworkSecurityResult(
          isAllowed: false,
          reason: 'No internet connection',
          networkType: 'None',
        );
      }

      // If connected via WiFi, check WiFi name and IP
      if (connectivityResult == ConnectivityResult.wifi) {
        return await _checkWiFiSecurity();
      }

      // If connected via mobile/ethernet, check IP range
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.ethernet) {
        return await _checkIpRangeSecurity();
      }

      return NetworkSecurityResult(
        isAllowed: false,
        reason: 'Unknown connection type',
        networkType: connectivityResult.toString(),
      );
    } catch (e) {
      return NetworkSecurityResult(
        isAllowed: false,
        reason: 'Network check failed: $e',
        networkType: 'Error',
      );
    }
  }

  /// Check WiFi network security
  static Future<NetworkSecurityResult> _checkWiFiSecurity() async {
    try {
      final info = NetworkInfo();

      String? wifiName;
      String? ipAddress;

      // Try to get network info, but handle web platform limitations
      try {
        wifiName = await info.getWifiName();
        ipAddress = await info.getWifiIP();
      } catch (e) {
        // On web, these methods are not supported
        // We'll use IP-based validation instead
        wifiName = null;
        ipAddress = null;
      }

      // Clean WiFi name (remove quotes if present)
      if (wifiName != null) {
        wifiName = wifiName.replaceAll('"', '');
      }

      // Check if WiFi name is allowed
      bool isWiFiAllowed =
          wifiName != null &&
          _allowedWiFiNames.any(
            (allowed) =>
                wifiName!.toLowerCase().contains(allowed.toLowerCase()),
          );

      // Check if IP is in allowed range
      bool isIpAllowed =
          ipAddress != null &&
          _allowedIpRanges.any((range) => ipAddress!.startsWith(range));

      bool isAllowed = isWiFiAllowed || isIpAllowed;

      // For web platform or when network info is unavailable
      if (wifiName == null && ipAddress == null) {
        // On web, we can't get local network info directly
        // Check if this is a web platform and if we allow web access
        if (NetworkConfig.allowWebPlatform) {
          // Try to verify using public IP
          final publicIpResult = await _checkIpRangeSecurity();
          if (publicIpResult.isAllowed) {
            return publicIpResult; // Company public IP matches
          }

          // If public IP doesn't match but we're in non-strict mode, allow web access
          if (!NetworkConfig.strictMode) {
            return NetworkSecurityResult(
              isAllowed: true,
              reason:
                  'Web platform detected - Network restrictions relaxed for testing. Enable strictMode for production.',
              networkType: 'Web Platform (Testing Mode)',
              wifiName: 'N/A (Web)',
              ipAddress: 'N/A (Web)',
            );
          }

          // Strict mode - only allow if public IP matches
          return publicIpResult;
        } else {
          return NetworkSecurityResult(
            isAllowed: false,
            reason: 'Web platform not allowed in current configuration',
            networkType: 'Web Platform (Blocked)',
          );
        }
      }

      // For web platform, if we can't get WiFi info, allow based on IP only
      if (wifiName == null && ipAddress != null && isIpAllowed) {
        isAllowed = true;
      }

      // In non-strict mode, be more permissive
      if (!NetworkConfig.strictMode) {
        // If we have the right IP range, allow access even if WiFi name doesn't match
        if (isIpAllowed) {
          isAllowed = true;
        }
        // For web platforms where we can't get local info, allow access
        if (wifiName == null && ipAddress == null) {
          isAllowed = true;
        }
      }

      return NetworkSecurityResult(
        isAllowed: isAllowed,
        reason: isAllowed
            ? 'Connected to authorized network'
            : 'WiFi network not authorized. Current: $wifiName, IP: $ipAddress. WiFi allowed: $isWiFiAllowed, IP allowed: $isIpAllowed',
        networkType: 'WiFi',
        wifiName: wifiName,
        ipAddress: ipAddress,
      );
    } catch (e) {
      return NetworkSecurityResult(
        isAllowed: false,
        reason: 'WiFi check failed: $e',
        networkType: 'WiFi Error',
      );
    }
  }

  /// Check IP range security for mobile/ethernet connections
  static Future<NetworkSecurityResult> _checkIpRangeSecurity() async {
    try {
      // For mobile/ethernet, we can check public IP
      final response = await http
          .get(
            Uri.parse('https://api.ipify.org?format=text'),
            headers: {'User-Agent': 'CholSmart/1.0'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        String publicIp = response.body.trim();

        // Check if it matches company public IP
        bool isCompanyIp = publicIp == _companyPublicIp;

        return NetworkSecurityResult(
          isAllowed: isCompanyIp,
          reason: isCompanyIp
              ? 'Connected from authorized public IP'
              : 'Not connected from company network. Current IP: $publicIp',
          networkType: 'Mobile/Ethernet',
          publicIp: publicIp,
        );
      }

      return NetworkSecurityResult(
        isAllowed: false,
        reason: 'Could not verify public IP',
        networkType: 'Mobile/Ethernet',
      );
    } catch (e) {
      return NetworkSecurityResult(
        isAllowed: false,
        reason: 'IP check failed: $e',
        networkType: 'Mobile/Ethernet Error',
      );
    }
  }

  /// Get current network information for debugging
  static Future<Map<String, String?>> getCurrentNetworkInfo() async {
    try {
      final info = NetworkInfo();
      final connectivity = await Connectivity().checkConnectivity();

      String? wifiName = await info.getWifiName();
      String? wifiIP = await info.getWifiIP();
      String? wifiBSSID = await info.getWifiBSSID();

      // Clean WiFi name
      if (wifiName != null) {
        wifiName = wifiName.replaceAll('"', '');
      }

      return {
        'connectivity': connectivity.toString(),
        'wifiName': wifiName,
        'wifiIP': wifiIP,
        'wifiBSSID': wifiBSSID,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Configure allowed WiFi networks (call this to update the list)
  static void updateAllowedNetworks(
    List<String> wifiNames,
    List<String> ipRanges,
  ) {
    // In a real app, you might want to store this in secure storage
    // For now, you would need to update the constants above
  }
}

/// Result class for network security checks
class NetworkSecurityResult {
  final bool isAllowed;
  final String reason;
  final String networkType;
  final String? wifiName;
  final String? ipAddress;
  final String? publicIp;

  NetworkSecurityResult({
    required this.isAllowed,
    required this.reason,
    required this.networkType,
    this.wifiName,
    this.ipAddress,
    this.publicIp,
  });

  @override
  String toString() {
    return 'NetworkSecurityResult(isAllowed: $isAllowed, reason: $reason, type: $networkType)';
  }
}
