// BULLETPROOF VERSION - COPY THIS TO GOOGLE APPS SCRIPT
// This version handles all edge cases

function doGet(e) {
    return handleRequest(e);
}

function doPost(e) {
    return handleRequest(e);
}

function doOptions(e) {
    return createResponse({ success: true, message: 'CORS preflight handled' });
}

function handleRequest(e) {
    try {
        const action = (e && e.parameter && e.parameter.action) ? e.parameter.action : 'getEmployees';

        if (action === 'checkIn') {
            return handleCheckIn(e);
        }

        // Get spreadsheet - try multiple methods
        let spreadsheet;
        try {
            spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
            if (!spreadsheet) {
                throw new Error('No active spreadsheet');
            }
        } catch (error) {
            return createResponse({
                success: false,
                message: 'Script must be deployed from within a Google Sheet. Go to your Google Sheet -> Extensions -> Apps Script and deploy from there.'
            });
        }

        const employeesSheet = spreadsheet.getSheets()[0];
        const data = employeesSheet.getDataRange().getValues();

        if (data.length === 0) {
            return createResponse({ success: false, message: 'No data found in sheet' });
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
        return createResponse({
            success: false,
            message: `Script error: ${error.toString()}. Make sure script is deployed from within your Google Sheet.`
        });
    }
}

function handleCheckIn(e) {
    try {
        let employeeId, checkInType;

        if (e && e.parameter) {
            employeeId = e.parameter.employeeId;
            checkInType = e.parameter.checkInType || 'Check In';
        } else if (e && e.postData && e.postData.contents) {
            const checkInData = JSON.parse(e.postData.contents);
            employeeId = checkInData.employeeId;
            checkInType = checkInData.checkInType || 'Check In';
        } else {
            return createResponse({ success: false, message: 'No check-in data provided' });
        }

        if (!employeeId) {
            return createResponse({ success: false, message: 'Employee ID is required' });
        }

        // Get spreadsheet with error handling
        let spreadsheet;
        try {
            spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
            if (!spreadsheet) {
                throw new Error('No active spreadsheet found');
            }
        } catch (error) {
            return createResponse({
                success: false,
                message: 'Script must be bound to a Google Sheet. Deploy from Extensions -> Apps Script in your sheet.'
            });
        }

        // Try to get or create Attendances sheet
        let attendancesSheet;
        try {
            // First try to find existing Attendances sheet
            attendancesSheet = spreadsheet.getSheetByName('Attendances');
        } catch (error) {
            // If not found, try to use second sheet
            const sheets = spreadsheet.getSheets();
            if (sheets.length > 1) {
                attendancesSheet = sheets[1];
            } else {
                // Create new Attendances sheet
                try {
                    attendancesSheet = spreadsheet.insertSheet('Attendances');
                    attendancesSheet.getRange(1, 1, 1, 5).setValues([
                        ['Employee ID', 'Check-in Type', 'Timestamp', 'Date', 'Time']
                    ]);
                } catch (createError) {
                    return createResponse({
                        success: false,
                        message: `Cannot create Attendances sheet: ${createError.toString()}`
                    });
                }
            }
        }

        if (!attendancesSheet) {
            return createResponse({ success: false, message: 'No attendance sheet available' });
        }

        // Create timestamp
        const now = new Date();
        const timestamp = now.getTime();
        const dateStr = Utilities.formatDate(now, Session.getScriptTimeZone(), 'yyyy-MM-dd');
        const timeStr = Utilities.formatDate(now, Session.getScriptTimeZone(), 'HH:mm:ss');

        // Add attendance record
        try {
            attendancesSheet.appendRow([
                employeeId,
                checkInType,
                timestamp,
                dateStr,
                timeStr
            ]);
        } catch (writeError) {
            return createResponse({
                success: false,
                message: `Failed to write attendance: ${writeError.toString()}`
            });
        }

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
        return createResponse({
            success: false,
            message: `Check-in error: ${error.toString()}`
        });
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
        return createResponse({ success: false, message: `Authentication error: ${error.toString()}` });
    }
}

function createResponse(data) {
    return ContentService
        .createTextOutput(JSON.stringify(data))
        .setMimeType(ContentService.MimeType.JSON);
}

function testConnection() {
    try {
        const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
        if (!spreadsheet) {
            return 'ERROR: No active spreadsheet found. Make sure script is bound to a Google Sheet.';
        }

        const sheet = spreadsheet.getSheets()[0];
        const data = sheet.getDataRange().getValues();

        console.log('✅ Sheet name:', sheet.getName());
        console.log('✅ Data rows:', data.length);
        console.log('✅ Headers:', data[0]);

        if (data.length > 1) {
            console.log('✅ First employee:', data[1]);
        }

        return '✅ Connection test successful!';
    } catch (error) {
        return `❌ Connection test failed: ${error.toString()}`;
    }
}