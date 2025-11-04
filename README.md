# Chol Smart - Employee Management System

A Flutter application for employee check-in/check-out management with Google Sheets integration.

## Features

- **Employee Authentication**: Login using Employee ID and Password stored in Google Sheets
- **Dashboard**: View employee information after successful login
- **Google Sheets Integration**: Fetches employee data directly from Google Sheets using CSV export
- **Responsive UI**: Clean and modern Material Design interface

## Setup

### Prerequisites

- Flutter SDK (3.9.0 or later)
- Android Studio / VS Code with Flutter extensions
- Internet connection for Google Sheets access

### Installation

1. Clone the repository:

```bash
git clone https://github.com/kongvannak-jpg/chol_smart.git
cd chol_smart
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the application:

```bash
flutter run
```

## Google Apps Script Integration

The app connects to Google Sheets via **Google Apps Script** for secure data access:

| Employee ID | Name        | Position  | Password |
| ----------- | ----------- | --------- | -------- |
| 1995        | Kong Vannak | Developer | 123      |
| 1996        | Rethy       | Developer | 123      |

### Current Setup:

- **Sheet ID**: `1W2FhTNAs1mx0Md01IkDnMK9LtYDN2m8r5u0A7ngKR1k`
- **Web App URL**: Deployed and configured via Google Apps Script
- **Access**: Secure (sheet can remain private)
- **Columns**: Employee ID, Name, Position, Password
- **Method**: RESTful API via Google Apps Script

### Making Your Sheet Public:

1. Open your Google Sheet
2. Click "Share" button
3. Change access to "Anyone with the link can view"
4. Copy the sheet ID from the URL

### Updating Sheet Configuration:

To use your own Google Sheet, update the `_sheetId` in `lib/services/google_sheets_service.dart`:

```dart
static const String _sheetId = 'YOUR_SHEET_ID_HERE';
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── pages/
│   ├── login_page.dart      # Login UI
│   └── home_page.dart       # Dashboard after login
└── services/
    └── google_sheets_service.dart  # Google Sheets API integration
```

## How to Use

1. **Login**: Enter your Employee ID and Password from the Google Sheet
2. **Dashboard**: After successful login, view your employee information
3. **Logout**: Use the logout button in the app bar

## Test Credentials

From the provided Google Sheet:

- **Employee ID**: 1995, **Password**: 123 (Kong Vannak)
- **Employee ID**: 1996, **Password**: 123 (Rethy)

## Dependencies

- `http: ^1.1.0` - HTTP requests to fetch Google Sheets data
- `googleapis: ^13.2.0` - Google APIs integration
- `googleapis_auth: ^1.4.1` - Google authentication

## Security Notes

- Passwords are stored in plain text in the Google Sheet (for demo purposes)
- In production, consider using hashed passwords and secure authentication
- The Google Sheet must be publicly accessible for the CSV export to work

## Future Enhancements

- [ ] Check-in/Check-out functionality
- [ ] Time tracking
- [ ] Report generation
- [ ] Push notifications
- [ ] Offline mode support
- [ ] Secure authentication with OAuth

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
