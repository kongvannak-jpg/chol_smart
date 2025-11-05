# Fix Google Apps Script Error

## 🚨 **Current Error:**

```
TypeError: Cannot read properties of undefined (reading 'parameter')
doGet @ check_in.gs:6
```

## ✅ **Solution Steps:**

### **Step 1: Open Google Apps Script**

1. Go to your Google Sheet: https://docs.google.com/spreadsheets/d/1W2FhTNAs1mx0Md01IkDnMK9LtYDN2m8r5u0A7ngKR1k/edit
2. Click **Extensions** > **Apps Script**

### **Step 2: Replace ALL Code**

1. **Delete all existing code** in the editor
2. **Copy and paste** the entire contents of `google_apps_script_robust.js`
3. **Save** the project (Ctrl+S or Cmd+S)

### **Step 3: Test the Script**

1. In the Apps Script editor, select the `testScript` function from the dropdown
2. Click the **Run** button (▶️)
3. **Authorize** the script if prompted
4. Check the **Execution log** - should show "Test completed successfully"

### **Step 4: Deploy New Version**

1. Click **Deploy** > **Manage deployments**
2. Click the **Edit** (pencil) icon on your existing deployment
3. Change **Version** to "New version"
4. Add description: "Fixed parameter error handling"
5. Click **Deploy**

### **Step 5: Test with Flutter App**

1. Go back to your Flutter app
2. Click **"🔧 Test Connection"**
3. Should work without errors now!

## 🔧 **What Was Fixed:**

- Added null checks for `e`, `e.parameter`, and `e.postData`
- Added comprehensive error handling and logging
- Added data validation for rows and columns
- Added a `testScript()` function for manual testing
- Better error messages for debugging

## 📋 **If Still Having Issues:**

### **Option A: Check Execution Log**

1. In Apps Script editor, click **Executions** (left sidebar)
2. Look for error details in recent executions

### **Option B: Use CSV Method (Fallback)**

If Google Apps Script continues to have issues, the app is already configured to work with the CSV method:

1. Make sure your Google Sheet is public
2. The app will work with the CSV export method instead

### **Option C: Test URL Manually**

Test your deployed URL in browser:

```
https://script.google.com/macros/s/AKfycbyLfUH68dE0R1WF7Fy05r_iqbhJmiS4OZCtsoyJzWzU0uXgngGWuXSYK8tkwixzEMDfcw/exec
```

Should return JSON data with your employees.

## 🎯 **Expected Result:**

After following these steps, both the Google Apps Script and CSV methods should work perfectly!
