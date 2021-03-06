<##########################################################################
# Project: Backup
# File: 03_delete_from_imagedata_and_update_mystratus.ps1
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 19/10/2020
# Description: Delete files from imagedata that were archived in external HD
#               and update session status on My Stratus
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

# importing classes and functions
. C:\workspace\scripts\brisbane\functions\tpsLib.ps1

$LOG_ROOT = "\\192.168.254.5\IT\AutoScripts\Logs\PowerShell\03-delete-from-imagedata-and-update-mystratus\";
$imageData    = "\\192.168.254.5\imagedata\01_CLIENT_FOLDER";
$externalHD   = "H:\Archives";
$statusToDelete = "Archive Pending";
$statusPosDelete = "Secondary Archive Pending";
$archiveName = "Archived to FINDING NEMO 5";

logToFile $LOG_ROOT "Retrieving sessions from External HardDrive"
$archive = $(getSessionArchivedInDisk $externalHD $LOG_ROOT)

for ($i = 0; $i -lt $archive.length; $i++) {
        
    try {

        if (!(Test-path -Path $($imageData  + "\" + $archive[$i].folder))) {
            logToFile $LOG_ROOT $("Session " + $archive[$i].sessionNumber + " does not exist in " `
                                +  $($imageData  + "\" + $archive[$i].folder) ) "ERROR"                
        }        
        else {

            $sessionInImageData = getMystratusSession $archive[$i].sessionNumber $imageData $archive[$i].folder $LOG_ROOT
            
            
            if ( $sessionInImageData.numberOfEditsFiles -ne $archive[$i].numberOfEditsFiles ) {
                logToFile $LOG_ROOT $("The session " + $sessionInImageData.sessionNumber + " has different number of files in EDIT folder." `
                + "`nThis session will not be deleted from Imagedata!" `
                + "`nImagedata EDIT folder: " + $sessionInImageData.numberOfEditsFiles + " files." `
                + "`nArchive EDIT folder: " + $archive[$i].numberOfEditsFiles + " files."`
                ) "ERROR"
            }
            elseif ( $sessionInImageData.numberOfSelectsFiles -ne $archive[$i].numberOfSelectsFiles ) {
                logToFile $LOG_ROOT $("The session " + $sessionInImageData.sessionNumber + " has different number of files in SELECTS folder." `
                + "`nThis session will not be deleted from Imagedata!" `
                + "`nImagedata SELECTS folder: " + $sessionInImageData.numberOfSelectsFiles + " files." `
                + "`nArchive SELECTS folder: " + $archive[$i].numberOfSelectsFiles + " files." `
                ) "ERROR"
            }
           <# elseif ( $sessionInImageData.numberOfProductionsFiles -ne $archive[$i].numberOfProductionsFiles ) {
                logToFile $LOG_ROOT $("The session " + $sessionInImageData.sessionNumber + " has different number of files in PRODUCTIONS folder." `
                + "`nThis session will not be deleted from Imagedata!" `
                + "`nImagedata PRODUCTIONS folder: " + $sessionInImageData.numberOfProductionsFiles + " files." `
                + "`nArchive PRODUCTIONS folder: " + $archive[$i].numberOfProductionsFiles + " files." `
                ) "ERROR"
            }
            #>
            elseif ( $sessionInImageData.status.Trim() -ne $statusToDelete.Trim() ) {
                logToFile $LOG_ROOT $("The session status " + $sessionInImageData.sessionNumber + " is different of " + $statusToDelete `
                + "`nThis session will not be deleted from Imagedata!" `
                ) "ERROR"
            }
            elseif ($sessionInImageData.folder.length -le 10) {
                logToFile $LOG_ROOT $("The folder name " + $sessionInImageData.folder + " is not compatible for session " + $sessionInImageData.sessionNumber `
                + "`nThis session will not be deleted from Imagedata!" `
                ) "ERROR"
            }
            else { ## steps above are fine, then delete!
                $itemToDelete = $($sessionInImageData.path + "\" + $sessionInImageData.folder);
                logToFile $LOG_ROOT $("Removing " + $itemToDelete + " from imagedata.") "INFO"
                try {
                    ##  Remove-Item $itemToDelete -Force -Recurse; # it does not delete _UPLOADS folders
                    Get-ChildItem -Path $itemToDelete -Recurse -force | Where-Object { -not ($_.psiscontainer) } | Remove-Item –Force
                    Remove-Item -Recurse -Force $itemToDelete
                }
                catch {
                    logToFile $LOG_ROOT $("Unknown error trying deleting folder " + $itemToDelete) "ERROR" -exceptionObj $_                     
                }

                ## If folder removed from imagedata, update status on MyStratus
                try {
                    if (!(Test-path -Path $itemToDelete -ErrorAction Stop | Out-Null )) {
                        logToFile $LOG_ROOT $($itemToDelete + " DELETED! Updating My Stratus session status...") "INFO"                
                        updateMyStratusSessionStatus $sessionInImageData.sessionNumber $statusPosDelete $archiveName
                    }
                } 
                catch [UnauthorizedAccessException] {
                    logToFile $LOG_ROOT $("Unauthorized Access Exception evaluating deleted folder " + $($sessionInImageData.path + "\" + $sessionInImageData.folder)) "ERROR" -exceptionObj $_                                         
                }
                catch {
                    logToFile $LOG_ROOT $("Unknown error evaluating deleted folder " + $($sessionInImageData.path + "\" + $sessionInImageData.folder)) "ERROR" -exceptionObj $_                     
                }                    
            }
        }
    }
    catch [UnauthorizedAccessException] {
        logToFile $LOG_ROOT $("Unauthorized Access Exception") "ERROR" -exceptionObj $_                                         
    }
    catch {
        logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
    }

}



