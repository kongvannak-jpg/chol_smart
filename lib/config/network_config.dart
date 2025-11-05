// Company Network Security Configuration
// Update these settings with your actual company network information

class NetworkConfig {
  // ================================================
  // COMPANY WIFI NETWORKS
  // ================================================
  // Add your company WiFi network names here
  // The app will allow access if connected to any of these networks
  static const List<String> allowedWiFiNames = [
    'MyLekha Office', // Your actual WiFi name from netsh wlan show interfaces
    'CompanyGuest', // Guest network (if you have one)
    'CompanyOffice', // Office WiFi (if you have additional networks)
    'Company5G', // 5G network (if you have one)
    // Add more WiFi names as needed
  ];

  // ================================================
  // COMPANY IP ADDRESS RANGES
  // ================================================
  // Add your company's local network IP ranges
  // Based on your ipconfig, your network uses 192.168.18.x
  static const List<String> allowedIpRanges = [
    '192.168.18', // Your current network (192.168.18.46)
    '192.168.1', // Common office network range
    '10.0.0', // Corporate network range
    '172.16', // Another corporate range
    // Add your company's specific IP ranges
  ];

  // ================================================
  // COMPANY PUBLIC IP ADDRESS
  // ================================================
  // Your company's public IP address (from curl ifconfig.me)
  // This is used to verify access from company internet connection
  static const String companyPublicIp =
      '118.67.205.159'; // Your current public IP

  // ================================================
  // SECURITY SETTINGS
  // ================================================
  // How strict should the network checking be?
  static const bool strictMode =
      true; // Set to true for production - only allow company network

  // How often to check network (in minutes)
  static const int networkCheckInterval = 5;

  // Allow mobile data if public IP matches?
  static const bool allowMobileWithCorrectPublicIp = true;

  // Allow web browsers (where network info is limited)?
  static const bool allowWebPlatform = true;

  // ================================================
  // INSTRUCTIONS FOR SETUP:
  // ================================================
  /*
  1. UPDATE WIFI NAMES:
     - Replace 'YourCompanyWiFi' with your actual WiFi network name
     - Add all company WiFi networks (main, guest, different floors, etc.)
     
  2. UPDATE IP RANGES:
     - Check your router configuration to see what IP ranges your company uses
     - Your current range is 192.168.18.x (based on 192.168.18.46)
     - Add other ranges if your company has multiple subnets
     
  3. UPDATE PUBLIC IP:
     - Run 'curl ifconfig.me' from company network to get public IP
     - Update companyPublicIp with the result
     - Note: Public IP may change, so consider this for maintenance
     
  4. TESTING:
     - Set strictMode = false for initial testing
     - Use the Network Guard page to see current network details
     - Gradually make settings more restrictive
     
  5. DEPLOYMENT:
     - Set strictMode = true for production
     - Test from different locations to ensure it works correctly
  */
}

// Example of how to get your network information:
/*
Windows:
- ipconfig                    (shows local IP addresses)
- curl ifconfig.me           (shows public IP)
- netsh wlan show profiles   (shows WiFi networks)

Android/iOS:
- Check WiFi settings for network name (SSID)
- Use network info apps to see IP details
*/
