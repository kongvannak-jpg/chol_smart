// COPY THIS ENTIRE CODE TO YOUR GOOGLE APPS SCRIPT
// Go to Extensions > Apps Script in your Google Sheet and replace ALL code with this

function doGet(e) {
    return handleRequest(e);
}

function doPost(e) {
    return handleRequest(e);
}

function doOptions(e) {
    // Handle CORS preflight requests
    return createResponse({ success: true, message: 'CORS preflight handled' });
}

function handleRequest(e) {
    try {
        // Handle different actions based on URL parameters
        const action = (e && e.parameter && e.parameter.action) ? e.parameter.action : 'getEmployees';

        if (action === 'checkIn') {
            return handleCheckIn(e);
        }

        // Default: Get employees from first sheet
        const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
        const employeesSheet = spreadsheet.getSheets()[0]; // Employees sheet

        // Get all data from the employees sheet
        const data = employeesSheet.getDataRange().getValues();

        if (data.length === 0) {
            return createResponse({ success: false, message: 'No data found' });
        }

        const headers = data[0]; // First row contains headers
        const employees = [];

        // Convert each row to an employee object
        for (let i = 1; i < data.length; i++) {
            const row = data[i];
            const employee = {};

            // Map each column to its header
            for (let j = 0; j < headers.length; j++) {
                employee[headers[j]] = row[j];
            }

            employees.push(employee);
        }

        // If it's a POST request with credentials, authenticate
        if (e && e.postData && e.postData.contents) {
            return authenticateEmployee(e.postData.contents, employees);
        }

        // Otherwise return all employees
        return createResponse({ success: true, data: employees });

    } catch (error) {
        return createResponse({ success: false, message: error.toString() });
    }
}

// Handle check-in requests
function handleCheckIn(e) {
    try {
        // Get parameters from either GET or POST request
        let employeeId, checkInType;

        if (e && e.parameter) {
            // GET request parameters
            employeeId = e.parameter.employeeId;
            checkInType = e.parameter.checkInType || 'Check In';
        } else if (e && e.postData && e.postData.contents) {
            // POST request data
            const checkInData = JSON.parse(e.postData.contents);
            employeeId = checkInData.employeeId;
            checkInType = checkInData.checkInType || 'Check In';
        } else {
            return createResponse({ success: false, message: 'No check-in data provided' });
        }

        if (!employeeId) {
            return createResponse({ success: false, message: 'Employee ID is required' });
        }

        // Get the spreadsheet and attendances sheet
        const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
        let attendancesSheet;

        // Try to find the Attendances sheet
        try {
            attendancesSheet = spreadsheet.getSheetByName('Attendances');
        } catch (error) {
            // If no "Attendances" sheet, try to get the second sheet
            const sheets = spreadsheet.getSheets();
            if (sheets.length > 1) {
                attendancesSheet = sheets[1]; // Second sheet
            } else {
                // If only one sheet, create a new "Attendances" sheet
                attendancesSheet = spreadsheet.insertSheet('Attendances');
                // Add headers
                attendancesSheet.getRange(1, 1, 1, 5).setValues([
                    ['Employee ID', 'Check-in Type', 'Timestamp', 'Date', 'Time']
                ]);
            }
        }

        if (!attendancesSheet) {
            return createResponse({ success: false, message: 'Could not create or find Attendances sheet' });
        }

        // Create timestamp
        const now = new Date();
        const timestamp = now.getTime();
        const dateStr = Utilities.formatDate(now, Session.getScriptTimeZone(), 'yyyy-MM-dd');
        const timeStr = Utilities.formatDate(now, Session.getScriptTimeZone(), 'HH:mm:ss');

        // Add new row to attendances sheet
        // Columns: Employee ID, Check-in Type, Timestamp, Date, Time
        attendancesSheet.appendRow([
            employeeId,
            checkInType,
            timestamp,
            dateStr,
            timeStr
        ]);

        return createResponse({
            success: true,
            message: `${checkInType} recorded successfully`,
            data: {
                employeeId: employeeId,
                checkInType: checkInType,
                timestamp: timestamp,
                date: dateStr,
                time: timeStr
            }
        });

    } catch (error) {
        return createResponse({ success: false, message: `Check-in error: ${error.toString()}` });
    }
}

function authenticateEmployee(postData, employees) {
    try {
        const credentials = JSON.parse(postData);
        const employeeId = String(credentials.employeeId);
        const password = String(credentials.password);

        // Find matching employee
        for (let i = 0; i < employees.length; i++) {
            const employee = employees[i];

            if (String(employee['Employee ID']) === employeeId &&
                String(employee['Password']) === password) {
                return createResponse({ success: true, data: employee });
            }
        }

        return createResponse({ success: false, message: 'Invalid credentials' });

    } catch (error) {
        return createResponse({ success: false, message: 'Authentication error' });
    }
}

function createResponse(data) {
    return ContentService
        .createTextOutput(JSON.stringify(data))
        .setMimeType(ContentService.MimeType.JSON);
}

// Test function - run this to check if everything works
function testConnection() {
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = spreadsheet.getSheets()[0];
    const data = sheet.getDataRange().getValues();

    console.log('Sheet name:', sheet.getName());
    console.log('Data rows:', data.length);
    console.log('Headers:', data[0]);

    if (data.length > 1) {
        console.log('First employee:', data[1]);
    }

    return 'Test successful!';
}