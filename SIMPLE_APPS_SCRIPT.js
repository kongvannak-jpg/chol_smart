// SIMPLE VERSION - COPY THIS TO GOOGLE APPS SCRIPT
// This version uses only the first sheet for everything

function doGet(e) {
    return handleRequest(e);
}

function doPost(e) {
    return handleRequest(e);
}

function handleRequest(e) {
    try {
        const action = (e && e.parameter && e.parameter.action) ? e.parameter.action : 'getEmployees';

        if (action === 'checkIn') {
            return handleCheckIn(e);
        }

        // Default: Get employees
        const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
        const sheet = spreadsheet.getSheets()[0];
        const data = sheet.getDataRange().getValues();

        if (data.length === 0) {
            return createResponse({ success: false, message: 'No data found' });
        }

        const headers = data[0];
        const employees = [];

        for (let i = 1; i < data.length; i++) {
            const row = data[i];
            const employee = {};
            for (let j = 0; j < headers.length; j++) {
                employee[headers[j]] = row[j];
            }
            employees.push(employee);
        }

        if (e && e.postData && e.postData.contents) {
            return authenticateEmployee(e.postData.contents, employees);
        }

        return createResponse({ success: true, data: employees });

    } catch (error) {
        return createResponse({ success: false, message: error.toString() });
    }
}

function handleCheckIn(e) {
    try {
        let employeeId, checkInType;

        if (e && e.parameter) {
            employeeId = e.parameter.employeeId;
            checkInType = e.parameter.checkInType || 'Check In';
        } else {
            return createResponse({ success: false, message: 'No check-in data provided' });
        }

        if (!employeeId) {
            return createResponse({ success: false, message: 'Employee ID is required' });
        }

        // Use the first sheet and add attendance data at the end
        const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
        const sheet = spreadsheet.getSheets()[0];

        // Find an empty area to add attendance data (after existing data + some gap)
        const lastRow = sheet.getLastRow();
        const attendanceRow = lastRow + 2; // Leave a gap

        // Create timestamp
        const now = new Date();
        const dateStr = Utilities.formatDate(now, Session.getScriptTimeZone(), 'yyyy-MM-dd');
        const timeStr = Utilities.formatDate(now, Session.getScriptTimeZone(), 'HH:mm:ss');

        // Add attendance record
        sheet.getRange(attendanceRow, 1, 1, 5).setValues([[
            employeeId,
            checkInType,
            now.getTime(),
            dateStr,
            timeStr
        ]]);

        return createResponse({
            success: true,
            message: `${checkInType} recorded successfully`,
            data: {
                employeeId: employeeId,
                checkInType: checkInType,
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

function testConnection() {
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = spreadsheet.getSheets()[0];
    const data = sheet.getDataRange().getValues();

    console.log('Sheet name:', sheet.getName());
    console.log('Data rows:', data.length);
    console.log('Headers:', data[0]);

    return 'Simple test successful!';
}