<##########################################################################
# Project: Backup
# File: evaluate_archive.ps1
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 02/10/2020
# Description: Get sessions with status "Archive Pending" and compare with
#              the disk archive exporting a report CSV
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
$imageData    = "\\192.168.33.46\imagedata\01_CLIENT_FOLDER\";
$externalHD   = "H:\Archives" #"G:\Archives\" #"H:\Archives" #"E:\" #  "F:\Brisbane\"
$filter = "Archive Pending";
$file   ='C:\archiveworks\Session_Status_Report_' + $filter.Replace(' ','_') + '_' +  (Get-Date -format "yyyyMMdd-hhmm") + ".csv"

logToFile $LOG_ROOT "Starting evaluate_archive ******************************************************"

logToFile $LOG_ROOT "Retrieving sessions from External HardDrive"
$archive = $(getSessionArchivedInDisk $externalHD $LOG_ROOT)

logToFile $LOG_ROOT "Retrieving sessions from ImageData"
$result = $(getMystratusSessionStatus $imageData $filter $LOG_ROOT);

# report itens found in imageData and archive
for ($i = 0; $i -lt $result.length; $i++) {
    try {

        $nItemFound = findItemInArrayOfObjects $result[$i] $archive

        if ($nItemFound -gt 0) {
            Add-Content $file $( $result[$i].sessionNumber + "," + $result[$i].status + "," + $result[$i].path + "," + $result[$i].folder + "," `
            + $result[$i].numberOfEditsFiles.tostring() + "," + $result[$i].numberOfProductionsFiles.tostring() + "," `
            + $result[$i].numberOfSelectsFiles.tostring() + "," + $result[$i].numberOfUploadsFiles.tostring()  + "," `
            + $result[$i].numberOfWorkingFiles.tostring()  + "," + $result[$i].statisticsDate + "," `
            `
            + $archive[$nItemFound].sessionNumber + "," + $archive[$nItemFound].status + "," + $archive[$nItemFound].path + "," + $archive[$nItemFound].folder + "," `
            + $archive[$nItemFound].numberOfEditsFiles.tostring() + "," + $archive[$nItemFound].numberOfProductionsFiles.tostring() + "," `
            + $archive[$nItemFound].numberOfSelectsFiles.tostring() + "," + $archive[$nItemFound].numberOfUploadsFiles.tostring()  + "," `
            + $archive[$nItemFound].numberOfWorkingFiles.tostring()  + "," + $archive[$nItemFound].statisticsDate)
        }
    }

    catch {
        logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
    }
} 

if ($result.length -eq 0) {
    if ($filter) {
        $message = "with filter " + $filter
    } 
    logToFile $LOG_ROOT ("No sessions found " + $message + " in " + $imageData )  "WARNING"    
}

if ($archive.length -eq 0) {
    logToFile $LOG_ROOT ("No sessions found in " + $externalHD ) "WARNING"    
}

logToFile $LOG_ROOT "Ending evaluate_archive ******************************************************" "INFO"