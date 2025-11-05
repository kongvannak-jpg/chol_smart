// Simplified Google Apps Script with robust error handling
// Go to Extensions > Apps Script and replace ALL existing code with this

function doGet(e) {
    Logger.log('doGet called with: ' + JSON.stringify(e));

    try {
        // Handle JSONP requests if callback parameter is present
        if (e && e.parameter && e.parameter.callback) {
            return handleJSONP(e);
        }

        // Regular GET request - fetch all employee data
        const sheet = getEmployeeSheet();

        if (!sheet) {
            return createResponse({ success: false, message: 'Could not access spreadsheet' });
        }

        const data = sheet.getDataRange().getValues();

        if (data.length === 0) {
            return createResponse({ success: false, message: 'No data found in sheet' });
        }

        const headers = data[0];
        const employees = [];

        // Convert rows to objects
        for (let i = 1; i < data.length; i++) {
            const row = data[i];
            if (row && row.length > 0) {  // Check if row exists and has data
                const employee = {};

                headers.forEach((header, index) => {
                    if (header && index < row.length) {  // Safety checks
                        employee[header] = row[index];
                    }
                });

                employees.push(employee);
            }
        }

        Logger.log('Returning ' + employees.length + ' employees');
        return createResponse({ success: true, data: employees });

    } catch (error) {
        Logger.log('Error in doGet: ' + error.toString());
        return createResponse({ success: false, message: 'Server error: ' + error.toString() });
    }
}

function doPost(e) {
    Logger.log('doPost called with: ' + JSON.stringify(e));

    try {
        // Validate POST data
        if (!e || !e.postData || !e.postData.contents) {
            return createResponse({ success: false, message: 'No POST data received' });
        }

        let requestData;
        try {
            requestData = JSON.parse(e.postData.contents);
        } catch (parseError) {
            return createResponse({ success: false, message: 'Invalid JSON in POST data' });
        }

        const employeeId = requestData.employeeId;
        const password = requestData.password;

        if (!employeeId || !password) {
            return createResponse({ success: false, message: 'Missing employeeId or password' });
        }

        const sheet = getEmployeeSheet();

        if (!sheet) {
            return createResponse({ success: false, message: 'Could not access spreadsheet for authentication' });
        }

        const data = sheet.getDataRange().getValues();

        if (data.length === 0) {
            return createResponse({ success: false, message: 'No employee data found in sheet' });
        } const headers = data[0];

        // Find employee with matching credentials
        for (let i = 1; i < data.length; i++) {
            const row = data[i];
            if (row && row.length > 0) {
                const employee = {};

                headers.forEach((header, index) => {
                    if (header && index < row.length) {
                        employee[header] = row[index];
                    }
                });

                // Check credentials (convert to string for comparison)
                if (String(employee['Employee ID']) === String(employeeId) &&
                    String(employee['Password']) === String(password)) {
                    Logger.log('Authentication successful for employee: ' + employeeId);
                    return createResponse({ success: true, data: employee });
                }
            }
        }

        Logger.log('Authentication failed for employee: ' + employeeId);
        return createResponse({ success: false, message: 'Invalid employee ID or password' });

    } catch (error) {
        Logger.log('Error in doPost: ' + error.toString());
        return createResponse({ success: false, message: 'Authentication error: ' + error.toString() });
    }
}

// Helper function to create consistent responses
function createResponse(data) {
    return ContentService
        .createTextOutput(JSON.stringify(data))
        .setMimeType(ContentService.MimeType.JSON);
}

// Handle JSONP requests (for CORS workaround)
function handleJSONP(e) {
    Logger.log('handleJSONP called');

    try {
        if (!e || !e.parameter || !e.parameter.callback) {
            return createResponse({ success: false, message: 'Invalid JSONP callback' });
        }

        const callback = e.parameter.callback;
        const sheet = getEmployeeSheet();

        if (!sheet) {
            return ContentService
                .createTextOutput(callback + '(' + JSON.stringify({ success: false, message: 'Could not access spreadsheet' }) + ')')
                .setMimeType(ContentService.MimeType.JAVASCRIPT);
        }

        const data = sheet.getDataRange().getValues();

        if (data.length === 0) {
            return ContentService
                .createTextOutput(callback + '(' + JSON.stringify({ success: false, message: 'No data found' }) + ')')
                .setMimeType(ContentService.MimeType.JAVASCRIPT);
        }

        const headers = data[0];
        const employees = [];

        // Convert rows to objects
        for (let i = 1; i < data.length; i++) {
            const row = data[i];
            if (row && row.length > 0) {
                const employee = {};

                headers.forEach((header, index) => {
                    if (header && index < row.length) {
                        employee[header] = row[index];
                    }
                });

                employees.push(employee);
            }
        }

        const responseData = { success: true, data: employees };
        return ContentService
            .createTextOutput(callback + '(' + JSON.stringify(responseData) + ')')
            .setMimeType(ContentService.MimeType.JAVASCRIPT);

    } catch (error) {
        Logger.log('Error in handleJSONP: ' + error.toString());
        const errorResponse = { success: false, message: error.toString() };
        return ContentService
            .createTextOutput(e.parameter.callback + '(' + JSON.stringify(errorResponse) + ')')
            .setMimeType(ContentService.MimeType.JAVASCRIPT);
    }
}

// Helper function to get the correct sheet
function getEmployeeSheet() {
    try {
        // Try to get the specific spreadsheet by ID
        const spreadsheet = SpreadsheetApp.openById('1W2FhTNAs1mx0Md01IkDnMK9LtYDN2m8r5u0A7ngKR1k');

        // Get the first sheet (index 0) which should contain employee data
        const sheet = spreadsheet.getSheets()[0];

        if (!sheet) {
            Logger.log('No sheets found in spreadsheet');
            return null;
        }

        Logger.log('Successfully accessed sheet: ' + sheet.getName());
        return sheet;

    } catch (error) {
        Logger.log('Error accessing specific spreadsheet, trying active sheet: ' + error.toString());

        // Fallback to active sheet method
        try {
            const activeSheet = SpreadsheetApp.getActiveSheet();
            if (activeSheet) {
                Logger.log('Using active sheet: ' + activeSheet.getName());
                return activeSheet;
            }
        } catch (activeError) {
            Logger.log('Active sheet also failed: ' + activeError.toString());
        }

        return null;
    }
}

// Test function you can run manually to check if the script works
function testScript() {
    Logger.log('=== Testing Script ===');

    try {
        const sheet = getEmployeeSheet();

        if (!sheet) {
            Logger.log('Test failed: Could not access any sheet');
            return;
        }

        const data = sheet.getDataRange().getValues();
        Logger.log('Sheet name: ' + sheet.getName());
        Logger.log('Data rows: ' + data.length);
        Logger.log('Sheet data: ' + JSON.stringify(data));

        if (data.length > 0) {
            Logger.log('Headers: ' + JSON.stringify(data[0]));
            if (data.length > 1) {
                Logger.log('First data row: ' + JSON.stringify(data[1]));
            }
        }

        Logger.log('Test completed successfully');
    } catch (error) {
        Logger.log('Test error: ' + error.toString());
    }
}