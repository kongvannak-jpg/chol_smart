import 'package:flutter/material.dart';
import '../services/network_security_service.dart';

class NetworkGuardPage extends StatefulWidget {
  const NetworkGuardPage({super.key});

  @override
  State<NetworkGuardPage> createState() => _NetworkGuardPageState();
}

class _NetworkGuardPageState extends State<NetworkGuardPage> {
  bool _isChecking = false;
  NetworkSecurityResult? _lastResult;
  Map<String, String?> _networkInfo = {};

  @override
  void initState() {
    super.initState();
    _checkNetwork();
    _loadNetworkInfo();
  }

  Future<void> _checkNetwork() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final result = await NetworkSecurityService.checkNetworkSecurity();
      setState(() {
        _lastResult = result;
      });

      // If network is now allowed, navigate back
      if (result.isAllowed && mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _loadNetworkInfo() async {
    final info = await NetworkSecurityService.getCurrentNetworkInfo();
    setState(() {
      _networkInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: const Text(
          'Network Access Restricted',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 100, color: Colors.red[400]),
            const SizedBox(height: 24),

            Text(
              'Company Network Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'This application can only be accessed from the company network. Please connect to the authorized WiFi or network.',
              style: TextStyle(fontSize: 16, color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Network Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Current Network Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_lastResult != null) ...[
                      _buildInfoRow(
                        'Status',
                        _lastResult!.isAllowed ? 'Authorized' : 'Unauthorized',
                      ),
                      _buildInfoRow(
                        'Connection Type',
                        _lastResult!.networkType,
                      ),
                      _buildInfoRow('Reason', _lastResult!.reason),
                      if (_lastResult!.wifiName != null)
                        _buildInfoRow('WiFi Network', _lastResult!.wifiName!),
                      if (_lastResult!.ipAddress != null)
                        _buildInfoRow('Local IP', _lastResult!.ipAddress!),
                      if (_lastResult!.publicIp != null)
                        _buildInfoRow('Public IP', _lastResult!.publicIp!),
                    ],

                    if (_networkInfo.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Network Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._networkInfo.entries
                          .where((entry) => entry.value != null)
                          .map(
                            (entry) => _buildInfoRow(
                              entry.key.toUpperCase(),
                              entry.value!,
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Retry Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkNetwork,
                icon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _isChecking ? 'Checking Network...' : 'Retry Connection',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Connect to your company WiFi network\n'
                    '2. Ensure you\'re on the company premises\n'
                    '3. Contact IT support if you continue to have issues\n'
                    '4. Tap "Retry Connection" after connecting',
                    style: TextStyle(color: Colors.blue[700], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
