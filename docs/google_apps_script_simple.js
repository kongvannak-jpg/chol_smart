// Ultra-simple Google Apps Script - Must be created from within your Google Sheet
// Go to your Google Sheet > Extensions > Apps Script > Replace ALL code with this

function doGet(e) {
    return handleRequest('GET', e);
}

function doPost(e) {
    return handleRequest('POST', e);
}

function handleRequest(method, e) {
    try {
        Logger.log(method + ' request received');

        // Get the spreadsheet that contains this script
        const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();

        if (!sheet) {
            return createJSONResponse({ success: false, message: 'No active sheet found' });
        }

        Logger.log('Sheet name: ' + sheet.getName());

        const range = sheet.getDataRange();
        const values = range.getValues();

        if (values.length === 0) {
            return createJSONResponse({ success: false, message: 'Sheet is empty' });
        }

        Logger.log('Found ' + values.length + ' rows of data');

        const headers = values[0];
        Logger.log('Headers: ' + JSON.stringify(headers));

        // Handle POST request (authentication)
        if (method === 'POST' && e && e.postData && e.postData.contents) {
            return handleAuthentication(values, headers, e.postData.contents);
        }

        // Handle GET request (fetch all employees)
        const employees = [];
        for (let i = 1; i < values.length; i++) {
            const row = values[i];
            const employee = {};

            for (let j = 0; j < headers.length && j < row.length; j++) {
                employee[headers[j]] = row[j];
            }

            employees.push(employee);
        }

        Logger.log('Returning ' + employees.length + ' employees');
        return createJSONResponse({ success: true, data: employees });

    } catch (error) {
        Logger.log('Error in handleRequest: ' + error.toString());
        return createJSONResponse({ success: false, message: error.toString() });
    }
}

function handleAuthentication(values, headers, postDataContents) {
    try {
        const requestData = JSON.parse(postDataContents);
        const employeeId = String(requestData.employeeId || '').trim();
        const password = String(requestData.password || '').trim();

        Logger.log('Authentication attempt for employee ID: ' + employeeId);

        if (!employeeId || !password) {
            return createJSONResponse({ success: false, message: 'Employee ID and password required' });
        }

        // Find employee
        for (let i = 1; i < values.length; i++) {
            const row = values[i];
            const employee = {};

            for (let j = 0; j < headers.length && j < row.length; j++) {
                employee[headers[j]] = row[j];
            }

            const rowEmployeeId = String(employee['Employee ID'] || '').trim();
            const rowPassword = String(employee['Password'] || '').trim();

            if (rowEmployeeId === employeeId && rowPassword === password) {
                Logger.log('Authentication successful');
                return createJSONResponse({ success: true, data: employee });
            }
        }

        Logger.log('Authentication failed - invalid credentials');
        return createJSONResponse({ success: false, message: 'Invalid employee ID or password' });

    } catch (error) {
        Logger.log('Authentication error: ' + error.toString());
        return createJSONResponse({ success: false, message: 'Authentication error: ' + error.toString() });
    }
}

function createJSONResponse(data) {
    return ContentService
        .createTextOutput(JSON.stringify(data))
        .setMimeType(ContentService.MimeType.JSON);
}

// Simple test function
function testConnection() {
    Logger.log('=== Test Connection ===');

    try {
        const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
        Logger.log('Active sheet: ' + sheet.getName());

        const data = sheet.getDataRange().getValues();
        Logger.log('Rows: ' + data.length);

        if (data.length > 0) {
            Logger.log('Headers: ' + JSON.stringify(data[0]));
            if (data.length > 1) {
                Logger.log('Sample row: ' + JSON.stringify(data[1]));
            }
        }

        Logger.log('Test successful!');
        return 'Test successful!';

    } catch (error) {
        Logger.log('Test failed: ' + error.toString());
        return 'Test failed: ' + error.toString();
    }
}