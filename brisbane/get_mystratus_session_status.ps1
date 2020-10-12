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

Add-Content $($LOG_FILE) $( "" + (Get-Date) + "| START | GET SESSION STATUS TASK | ******************************************************   ")

$dir    = "\\192.168.33.46\imagedata\01_CLIENT_FOLDER";
$log    = "\\192.168.33.46\IT\AutoScripts\Logs\PowerShell\brisbane_archive_process\" + (Get-Date).Year + "\";
$filter = "";

$result = getMystratusSessionStatus($dir, $filter, $log); 

for ($i = 0; $i -lt $result.length; $i++) {
    try {
        Add-Content $('C:\archiveworks\Session_Status_Report_' + $file + ".csv") $( $result[$i].Session + "," + $result[$i ].Status)
    }
    catch [System.Net.WebException] {
        Add-Content $($LOG_FILE) $( "" + (Get-Date) + "| ERROR | Session " + $result[$i].Session + " ")
    }
} 
Add-Content $($LOG_FILE) $( "" + (Get-Date) + "| END | FINISHED GET SESSION STATUS TASK | ******************************************************   ")

return $sessionToReturn 
