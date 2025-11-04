// Google Apps Script code to deploy in your Google Sheet
// Go to Extensions > Apps Script in your Google Sheet and paste this code

function doGet(e) {
    try {
        const sheet = SpreadsheetApp.getActiveSheet();
        const data = sheet.getDataRange().getValues();

        if (data.length === 0) {
            return ContentService
                .createTextOutput(JSON.stringify({ success: false, message: 'No data found' }))
                .setMimeType(ContentService.MimeType.JSON);
        }

        const headers = data[0];
        const employees = [];

        // Convert rows to objects
        for (let i = 1; i < data.length; i++) {
            const row = data[i];
            const employee = {};

            headers.forEach((header, index) => {
                employee[header] = row[index];
            });

            employees.push(employee);
        }

        return ContentService
            .createTextOutput(JSON.stringify({ success: true, data: employees }))
            .setMimeType(ContentService.MimeType.JSON);

    } catch (error) {
        return ContentService
            .createTextOutput(JSON.stringify({ success: false, message: error.toString() }))
            .setMimeType(ContentService.MimeType.JSON);
    }
}

function doPost(e) {
    try {
        const requestData = JSON.parse(e.postData.contents);
        const employeeId = requestData.employeeId;
        const password = requestData.password;

        if (!employeeId || !password) {
            return ContentService
                .createTextOutput(JSON.stringify({ success: false, message: 'Missing credentials' }))
                .setMimeType(ContentService.MimeType.JSON);
        }

        const sheet = SpreadsheetApp.getActiveSheet();
        const data = sheet.getDataRange().getValues();
        const headers = data[0];

        // Find employee
        for (let i = 1; i < data.length; i++) {
            const row = data[i];
            const employee = {};

            headers.forEach((header, index) => {
                employee[header] = row[index];
            });

            if (employee['Employee ID'] == employeeId && employee['Password'] == password) {
                return ContentService
                    .createTextOutput(JSON.stringify({ success: true, data: employee }))
                    .setMimeType(ContentService.MimeType.JSON);
            }
        }

        return ContentService
            .createTextOutput(JSON.stringify({ success: false, message: 'Invalid credentials' }))
            .setMimeType(ContentService.MimeType.JSON);

    } catch (error) {
        return ContentService
            .createTextOutput(JSON.stringify({ success: false, message: error.toString() }))
            .setMimeType(ContentService.MimeType.JSON);
    }
}