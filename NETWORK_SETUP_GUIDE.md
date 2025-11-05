# Company WiFi Security Setup Guide

## 🔧 How to Configure Your Company Network Security

### 1. **Find Your Company WiFi Information**

**On Windows (run these commands):**

```cmd
# Get your current IP address
ipconfig

# Get your public IP address
curl ifconfig.me

# See available WiFi networks
netsh wlan show profiles
```

**From your results:**

- Local IP: `192.168.18.46` (so your network range is `192.168.18`)
- Public IP: `118.67.205.159`
- WiFi Network: You'll need to find the actual name

### 2. **Update Network Configuration**

Edit the file: `lib/config/network_config.dart`

**Replace these settings with your actual values:**

```dart
// STEP 1: Add your actual WiFi network names
static const List<String> allowedWiFiNames = [
  'YOUR_ACTUAL_WIFI_NAME',    // Replace this!
  'CompanyGuest',             // If you have guest WiFi
  'CompanyOffice_5G',         // If you have 5G network
];

// STEP 2: Update IP ranges (your current range is correct)
static const List<String> allowedIpRanges = [
  '192.168.18',               // ✅ This matches your network
  '192.168.1',                // Add if you have other ranges
  '10.0.0',                   // Add if you have corporate networks
];

// STEP 3: Update public IP (this is correct from your curl command)
static const String companyPublicIp = '118.67.205.159';  // ✅ This is correct
```

### 3. **Testing the Security**

**For Initial Testing:**

1. Set `strictMode = false` in `network_config.dart`
2. Run the app and check the Network Guard page
3. Note down the network details shown
4. Update the configuration based on what you see

**For Production:**

1. Set `strictMode = true`
2. Test from different locations to ensure it blocks correctly
3. Test from company WiFi to ensure it allows access

### 4. **How It Works**

The app checks network access in 3 ways:

1. **WiFi Name Check**: If connected to WiFi, checks if the network name is in your allowed list
2. **IP Range Check**: Checks if your local IP address is in your company's ranges
3. **Public IP Check**: For mobile/ethernet, checks if public IP matches company IP

### 5. **Security Levels**

**Level 1 - WiFi Name Only:**

```dart
allowedWiFiNames = ['YourCompanyWiFi'];
allowedIpRanges = [];  // Empty - only check WiFi name
```

**Level 2 - IP Range Only:**

```dart
allowedWiFiNames = [];  // Empty - only check IP
allowedIpRanges = ['192.168.18'];
```

**Level 3 - Both (Recommended):**

```dart
allowedWiFiNames = ['YourCompanyWiFi'];
allowedIpRanges = ['192.168.18'];
```

### 6. **Troubleshooting**

**If employees can't access:**

- Check the Network Guard page for current network details
- Add the actual network name/IP to the configuration
- Temporarily set `strictMode = false` for testing

**If security is too loose:**

- Remove broader IP ranges
- Be more specific with WiFi names
- Set `strictMode = true`

### 7. **Maintenance**

**Monthly Tasks:**

- Check if your public IP has changed: `curl ifconfig.me`
- Update `companyPublicIp` if it changed
- Review allowed networks list

**When Adding New Offices:**

- Add new WiFi network names
- Add new IP ranges
- Test from new locations

### 8. **Example Commands to Run Now**

```cmd
# Find your WiFi network name
netsh wlan show profiles

# Example output:
# User profiles
# -------------
#     All User Profile : YourCompanyWiFi
#     All User Profile : CompanyGuest
```

Then update your config file with the actual names you see!

## 🚨 **IMPORTANT**:

Replace `YourCompanyWiFi` with your **actual WiFi network name** before deploying to employees!
