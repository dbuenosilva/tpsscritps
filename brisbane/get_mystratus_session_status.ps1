<##########################################################################
# Project: Backup
# File: get_mystratus_session_status.ps1
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 02/10/2020
# Description: Get session status of specific directory and return 
# to CSV file.                
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

# importing classes and functions
. C:\workspace\scripts\brisbane\functions\getMystratusSessionStatus.ps1
. C:\workspace\scripts\brisbane\functions\tpsLib.ps1

$LOG_ROOT = "\\192.168.33.46\IT\AutoScripts\Logs\PowerShell\retrieving_stratus_status\";
$dir = "\\192.168.33.46\imagedata\01_CLIENT_FOLDER\diego";
$filter = "";
$file = Get-Date -format "yyyyMMdd-hhmm";

logToFile $LOG_ROOT "Starting get_mystratus_session_status ******************************************************"

$result = $(getMystratusSessionStatus $dir $filter $LOG_ROOT);

for ($i = 0; $i -lt $result.length; $i++) {
    try {
        Add-Content $('C:\archiveworks\Session_Status_Report_' + $file + ".csv") $( $result[$i].Session + "," + $result[$i ].Status)
    }
    catch [System.Net.WebException] {
        logToFile $LOG_ROOT ("Session " + $result[$i].Session + " ") "ERROR"
    }
} 
logToFile $LOG_ROOT "Ending get_mystratus_session_status ******************************************************" "INFO"