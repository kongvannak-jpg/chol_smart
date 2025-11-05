# Fix Google Apps Script - Step by Step

## 🚨 **Current Error:**

`TypeError: Cannot read properties of null (reading 'getDataRange')`

This means the script can't access your spreadsheet properly.

## ✅ **Solution: Create Script from Within Your Sheet**

### **Step 1: Delete Current Apps Script Project**

1. In your current Apps Script tab, go to **Settings** (gear icon)
2. Click **Delete project**
3. Confirm deletion

### **Step 2: Create New Script from Your Sheet**

1. **Close** the Apps Script tab
2. Go directly to your Google Sheet: https://docs.google.com/spreadsheets/d/1W2FhTNAs1mx0Md01IkDnMK9LtYDN2m8r5u0A7ngKR1k/edit
3. In the sheet, click **Extensions** > **Apps Script**
4. This creates a new script **attached to your sheet**

### **Step 3: Replace Code**

1. **Delete all existing code** in the new Apps Script editor
2. **Copy ALL code** from `google_apps_script_simple.js`
3. **Paste** into the Apps Script editor
4. **Save** (Ctrl+S or Cmd+S)
5. **Rename** the project to "Chol Smart API"

### **Step 4: Test the Connection**

1. Select `testConnection` from the function dropdown
2. Click **Run** (▶️)
3. **Authorize** when prompted (click "Review permissions" → "Allow")
4. Check **Execution log** - should show:
   ```
   Active sheet: Sheet1
   Rows: 3
   Headers: ["Employee ID","Name","Position","Password"]
   Sample row: [1995,"Kong Vannak","Developer","123"]
   Test successful!
   ```

### **Step 5: Deploy Web App**

1. Click **Deploy** > **New deployment**
2. Click gear icon ⚙️ > Choose **Web app**
3. Set description: "Employee Authentication API"
4. **Execute as**: Me
5. **Who has access**: Anyone
6. Click **Deploy**
7. **Copy the Web App URL**

### **Step 6: Update Flutter Service**

1. Open `lib/services/google_apps_script_service.dart`
2. Replace the `_webAppUrl` with your new URL
3. Save the file

### **Step 7: Test Flutter App**

1. Restart your Flutter app
2. Click **"🔧 Test Connection"**
3. Try logging in with ID: `1995`, Password: `123`

## 🔧 **Why This Works:**

- Creating the script **from within the sheet** automatically links them
- Uses `getActiveSpreadsheet()` instead of trying to access by ID
- Simpler code with better error handling
- Direct connection to your specific sheet

## 📋 **If Still Having Issues:**

### **Check Your Sheet Structure:**

Make sure your sheet has this exact structure:
| Employee ID | Name | Position | Password |
|-------------|------|----------|----------|
| 1995 | Kong Vannak | Developer | 123 |
| 1996 | Rethy | Developer | 123 |

### **Check Permissions:**

- Sheet must be accessible to your Google account
- Apps Script needs authorization to read the sheet
- Web app needs to be deployed with correct permissions

## 🎯 **Expected Result:**

After following these steps, both the test function and your Flutter app should work perfectly!

The key is creating the Apps Script **from within your Google Sheet** rather than as a standalone project.
