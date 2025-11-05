import 'package:flutter/material.dart';
import '../services/network_security_service.dart';

class NetworkDebugPage extends StatefulWidget {
  const NetworkDebugPage({super.key});

  @override
  State<NetworkDebugPage> createState() => _NetworkDebugPageState();
}

class _NetworkDebugPageState extends State<NetworkDebugPage> {
  NetworkSecurityResult? _result;
  Map<String, String?> _networkInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkNetwork();
  }

  Future<void> _checkNetwork() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await NetworkSecurityService.checkNetworkSecurity();
      final info = await NetworkSecurityService.getCurrentNetworkInfo();

      setState(() {
        _result = result;
        _networkInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Debug'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Your Current Network Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Current Network Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('WiFi Name: MyLekha Office'),
                          Text('IP Address: 192.168.18.46'),
                          Text('Public IP: 118.67.205.159'),
                          Text('IP Range: 192.168.18.x'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Network Security Result
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _result?.isAllowed == true
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _result?.isAllowed == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Security Check Result',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _result?.isAllowed == true
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_result != null) ...[
                            _buildInfoRow(
                              'Status',
                              _result!.isAllowed ? 'ALLOWED' : 'BLOCKED',
                            ),
                            _buildInfoRow(
                              'Connection Type',
                              _result!.networkType,
                            ),
                            _buildInfoRow('Reason', _result!.reason),
                            if (_result!.wifiName != null)
                              _buildInfoRow(
                                'Detected WiFi',
                                _result!.wifiName!,
                              ),
                            if (_result!.ipAddress != null)
                              _buildInfoRow('Detected IP', _result!.ipAddress!),
                            if (_result!.publicIp != null)
                              _buildInfoRow('Public IP', _result!.publicIp!),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Raw Network Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Raw Network Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._networkInfo.entries.map(
                            (entry) =>
                                _buildInfoRow(entry.key, entry.value ?? 'null'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Configured Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Configuration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Allowed WiFi Networks',
                            'MyLekha Office, CompanyGuest, CompanyOffice, Company5G',
                          ),
                          _buildInfoRow(
                            'Allowed IP Ranges',
                            '192.168.18, 192.168.1, 10.0.0, 172.16',
                          ),
                          _buildInfoRow('Company Public IP', '118.67.205.159'),
                          _buildInfoRow('Strict Mode', 'false (testing mode)'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _checkNetwork,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Recheck Network'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_result?.isAllowed == true) {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Network access not authorized',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Continue to Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _result?.isAllowed == true
                                ? Colors.green[600]
                                : Colors.grey[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
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
            width: 140,
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
