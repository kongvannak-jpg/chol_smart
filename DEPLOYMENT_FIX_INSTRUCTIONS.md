# 🔧 Google Apps Script Deployment Fix

## Issue

The script is returning `TypeError: Cannot read properties of null (reading 'getSheets')` because `SpreadsheetApp.getActiveSpreadsheet()` returns null when the script is deployed as a web app.

## Solution

You need to use your specific spreadsheet ID in the script.

## Steps to Fix:

### 1. Get Your Spreadsheet ID

- Open your Google Sheet
- Look at the URL: `https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit`
- Copy the `SPREADSHEET_ID` part (the long string between `/d/` and `/edit`)

### 2. Update the Google Apps Script

Replace both instances of `YOUR_SPREADSHEET_ID` in the script with your actual spreadsheet ID:

**Line 28:**

```javascript
const spreadsheet =
  SpreadsheetApp.getActiveSpreadsheet() ||
  SpreadsheetApp.openById("YOUR_ACTUAL_SPREADSHEET_ID");
```

**Line 79:**

```javascript
const spreadsheet =
  SpreadsheetApp.getActiveSpreadsheet() ||
  SpreadsheetApp.openById("YOUR_ACTUAL_SPREADSHEET_ID");
```

### 3. Redeploy the Script

- Save the changes
- Deploy → Manage Deployments
- Click the edit icon next to your deployment
- Create new version
- Deploy

### 4. Alternative: Bind Script to Spreadsheet

Instead of using spreadsheet ID, you can bind the script directly to your sheet:

1. Open your Google Sheet
2. Extensions → Apps Script
3. Paste the code there (this automatically binds it to the sheet)
4. Deploy from within the bound script

### 5. Test Again

Once you've updated with your spreadsheet ID, the attendance system should work correctly.

## Example Spreadsheet ID Format:

`1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms`

Make sure your sheet has:

- First sheet: "Employees" (or any name) with employee data
- Second sheet: "Attendances" with columns for attendance tracking

Would you like me to help you update the script once you have your spreadsheet ID?
