# Google Apps Script Integration Setup

## 🎯 Overview

The app now uses **Google Apps Script** instead of direct CSV export for better security and control.

## 📋 What was deployed:

**Deployment ID**: `AKfycbyLfUH68dE0R1WF7Fy05r_iqbhJmiS4OZCtsoyJzWzU0uXgngGWuXSYK8tkwixzEMDfcw`

**Web App URL**: `https://script.google.com/macros/s/AKfycbyLfUH68dE0R1WF7Fy05r_iqbhJmiS4OZCtsoyJzWzU0uXgngGWuXSYK8tkwixzEMDfcw/exec`

## 🔧 How it works:

### 1. **GET Request** (Fetch all employees):

```
GET https://script.google.com/macros/s/AKfycbyLfUH68dE0R1WF7Fy05r_iqbhJmiS4OZCtsoyJzWzU0uXgngGWuXSYK8tkwixzEMDfcw/exec

Response:
{
  "success": true,
  "data": [
    {
      "Employee ID": "1995",
      "Name": "Kong Vannak",
      "Position": "Developer",
      "Password": "123"
    },
    {
      "Employee ID": "1996",
      "Name": "Rethy",
      "Position": "Developer",
      "Password": "123"
    }
  ]
}
```

### 2. **POST Request** (Authenticate employee):

```
POST https://script.google.com/macros/s/AKfycbyLfUH68dE0R1WF7Fy05r_iqbhJmiS4OZCtsoyJzWzU0uXgngGWuXSYK8tkwixzEMDfcw/exec

Body:
{
  "employeeId": "1995",
  "password": "123"
}

Response (Success):
{
  "success": true,
  "data": {
    "Employee ID": "1995",
    "Name": "Kong Vannak",
    "Position": "Developer",
    "Password": "123"
  }
}

Response (Failed):
{
  "success": false,
  "message": "Invalid credentials"
}
```

## 🚀 Testing:

1. **Run the app**: `flutter run`
2. **On login page**: Click "🔧 Test Connection" button
3. **Test options**:
   - "Test Get All Employees" - Fetches all employee data
   - "Test Login" - Tests authentication with ID: 1995, Password: 123

## ✅ Benefits of Google Apps Script:

- **Security**: Your Google Sheet doesn't need to be public
- **Control**: Full control over data access and validation
- **Error Handling**: Better error messages and handling
- **Customization**: Can add features like logging, validation, etc.
- **Performance**: Optimized queries and responses

## 🔒 Security Features:

1. **Private Sheet**: Your Google Sheet can remain private
2. **Controlled Access**: Only the deployed script can access the data
3. **Input Validation**: Server-side validation of credentials
4. **Error Handling**: Proper error responses without exposing sheet structure

## 🛠 Files Updated:

1. **`lib/services/google_apps_script_service.dart`** - New service with your Web App URL
2. **`lib/pages/login_page.dart`** - Updated to use new service + test button
3. **`lib/pages/test_connection_page.dart`** - New test page for debugging
4. **`lib/main.dart`** - Added test route
5. **`docs/google_apps_script.js`** - The script deployed to Google Apps Script

## 🎯 Test Credentials:

- **Employee ID**: 1995, **Password**: 123 (Kong Vannak)
- **Employee ID**: 1996, **Password**: 123 (Rethy)

## 📞 Support:

If you encounter issues:

1. Use the "🔧 Test Connection" button to diagnose problems
2. Check the Google Apps Script execution logs
3. Verify the Web App URL is correct
4. Ensure the Google Sheet structure matches expected format
