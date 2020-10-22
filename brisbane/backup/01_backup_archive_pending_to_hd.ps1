<##########################################################################
# Project: Backup
# File: 01_backup_archive_pending_to_hd.ps1
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 21/10/2020
# Description: Get sessions with status "Archive Pending" and copy to
#              an external hard disk to be use as archive 
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

# importing classes and functions
. C:\workspace\scripts\brisbane\functions\tpsLib.ps1

$LOG_ROOT = "\\192.168.254.5\IT\AutoScripts\Logs\PowerShell\01-backup-archive-pending-to-hd\";
$imageData    = "\\192.168.254.5\imagedata\01_CLIENT_FOLDER";
$externalHD   = "H:\Archives"
$filter = "Archive Pending";

logToFile $LOG_ROOT "Starting 01_backup_archive_pending_to_hd ******************************************************"

logToFile $LOG_ROOT "Retrieving sessions from ImageData"
$result = $(getListOfMystratusSessions $imageData $filter $LOG_ROOT);

# report itens found in imageData and archive
for ($i = 0; $i -lt $result.length; $i++) {

    try {

        $directoryToCopy = $($imageData  + "\" + $result[$i].folder)
        if (!(Test-path -Path $directoryToCopy)) {
            logToFile $LOG_ROOT $("Fail to copying session " + $result[$i].sessionNumber + " to External HardDrive " + $externalHD `
                                + "`nPath " + $directoryToCopy + " is not valid" ) "ERROR"
        }
        else {
            logToFile $LOG_ROOT $("Copying session " + $result[$i].sessionNumber + " to External HardDrive " + $externalHD) "INFO"
                       
            # creating directory on HD
            try {
                $sessionFolderInHD = $($externalHD + "\" + $result[$i].folder)
                if (!(Test-path -Path $sessionFolderInHD) ) {
                    New-Item -ItemType Directory $sessionFolderInHD;
                }
            }
            catch [System.IO.IOException] {
                Write-Output $(  "" + (Get-Date) + " ERROR creating directory " + $sessionFolderInHD);
                exit exit-gracefully(102);
            }
            catch {
                logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
            }  

            # copying Edits
            if ( $result[$i].numberOfEditsFiles -gt 0 ) {
                Copy-Item -Path  $($directoryToCopy + "\" + $result[$i].sessionNumber + "_Edits") -Destination $sessionFolderInHD -Recurse -Force
            }

            # copying Selects
            if ( $result[$i].numberOfEditsFiles -gt 0 ) {
                Copy-Item -Path  $($directoryToCopy + "\" + $result[$i].sessionNumber + "_Selects") -Destination $sessionFolderInHD -Recurse -Force
            }

            # copying Productions
            if ( $result[$i].numberOfEditsFiles -gt 0 ) {
                Copy-Item -Path  $($directoryToCopy + "\" + $result[$i].sessionNumber + "_Productions") -Destination $sessionFolderInHD -Recurse -Force
            }
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

logToFile $LOG_ROOT "Ending 01_backup_archive_pending_to_hd ******************************************************" "INFO"