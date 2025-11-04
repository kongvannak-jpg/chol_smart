// Google Apps Script code with CORS support for web applications
// Go to Extensions > Apps Script in your Google Sheet and replace ALL existing code with this

function doGet(e) {
    // Handle CORS preflight requests
    if (e.parameter.callback) {
        return handleJSONP(e);
    }
    
    try {
        const sheet = SpreadsheetApp.getActiveSheet();
        const data = sheet.getDataRange().getValues();

        if (data.length === 0) {
            return createCORSResponse({ success: false, message: 'No data found' });
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

        return createCORSResponse({ success: true, data: employees });

    } catch (error) {
        return createCORSResponse({ success: false, message: error.toString() });
    }
}

function doPost(e) {
    try {
        const requestData = JSON.parse(e.postData.contents);
        const employeeId = requestData.employeeId;
        const password = requestData.password;

        if (!employeeId || !password) {
            return createCORSResponse({ success: false, message: 'Missing credentials' });
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
                return createCORSResponse({ success: true, data: employee });
            }
        }

        return createCORSResponse({ success: false, message: 'Invalid credentials' });

    } catch (error) {
        return createCORSResponse({ success: false, message: error.toString() });
    }
}

// Helper function to create CORS-enabled responses
function createCORSResponse(data) {
    const output = ContentService
        .createTextOutput(JSON.stringify(data))
        .setMimeType(ContentService.MimeType.JSON);
    
    return output;
}

// Handle JSONP requests for better browser compatibility
function handleJSONP(e) {
    const callback = e.parameter.callback;
    
    try {
        const sheet = SpreadsheetApp.getActiveSheet();
        const data = sheet.getDataRange().getValues();

        if (data.length === 0) {
            return ContentService
                .createTextOutput(`${callback}(${JSON.stringify({ success: false, message: 'No data found' })})`)
                .setMimeType(ContentService.MimeType.JAVASCRIPT);
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
            .createTextOutput(`${callback}(${JSON.stringify({ success: true, data: employees })})`)
            .setMimeType(ContentService.MimeType.JAVASCRIPT);

    } catch (error) {
        return ContentService
            .createTextOutput(`${callback}(${JSON.stringify({ success: false, message: error.toString() })})`)
            .setMimeType(ContentService.MimeType.JAVASCRIPT);
    }
}