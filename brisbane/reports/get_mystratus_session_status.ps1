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
. C:\workspace\scripts\brisbane\functions\tpsLib.ps1

$LOG_ROOT = "\\192.168.33.46\IT\AutoScripts\Logs\PowerShell\retrieving-stratus-status\";
$dir    = "\\192.168.33.46\imagedata\01_CLIENT_FOLDER\diego\";
$filter = "" # "Archive Pending";
$file   ='C:\archiveworks\Session_Status_Report_' + $filter.Replace(' ','_') + '_' +  (Get-Date -format "yyyyMMdd-hhmm") + ".csv"

logToFile $LOG_ROOT "Starting get_mystratus_session_status ******************************************************"

$result = $(getMystratusSessionStatus $dir $filter $LOG_ROOT);

for ($i = 0; $i -lt $result.length; $i++) {
    try {
        Add-Content $file $( $result[$i].sessionNumber + "," + $result[$i].status + "," + $result[$i].path + "," + $result[$i].folder + "," `
        + $result[$i].numberOfEditsFiles.tostring() + "," + $result[$i].numberOfProductionsFiles.tostring() + "," `
        + $result[$i].numberOfSelectsFiles.tostring() + "," + $result[$i].numberOfUploadsFiles.tostring()  + "," `
        + $result[$i].numberOfWorkingFiles.tostring()  + "," + $result[$i].statisticsDate )
    }
    catch {
      logToFile $LOG_ROOT $("Session " + $result[$i].sessionNumber + " did not add in file " + $file.ToString()) "ERROR" -exceptionObj $_ 
    }
} 

if ($result.length -eq 0) {
    if ($filter) {
        $message = "with filter " + $filter
    } 
    logToFile $LOG_ROOT ("No sessions found " + $message)   "INFO"    
}

logToFile $LOG_ROOT "Ending get_mystratus_session_status ******************************************************" "INFO"