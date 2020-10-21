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

$LOG_ROOT = "\\192.168.33.46\IT\AutoScripts\Logs\PowerShell\03-delete-from-imagedata-and-update-mystratus\";
$imageData    = "\\192.168.33.46\imagedata\01_CLIENT_FOLDER\diego";
$externalHD   = "C:\archive";
$statusToDelete = "Secondary Archive Pending";
$statusPosDelete = "Secondary Archive Pending";
$archiveName = "Archived to FINDING NEMO 5";

logToFile $LOG_ROOT "Retrieving sessions from External HardDrive"
$archive = $(getSessionArchivedInDisk $externalHD $LOG_ROOT)

for ($i = 0; $i -lt $archive.length; $i++) {
        
    try {
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
            exit-gracefully(105);
        }
        elseif ( $sessionInImageData.numberOfProductionsFiles -ne $archive[$i].numberOfProductionsFiles ) {
            logToFile $LOG_ROOT $("The session " + $sessionInImageData.sessionNumber + " has different number of files in PRODUCTIONS folder." `
            + "`nThis session will not be deleted from Imagedata!" `
            + "`nImagedata PRODUCTIONS folder: " + $sessionInImageData.numberOfProductionsFiles + " files." `
            + "`nArchive PRODUCTIONS folder: " + $archive[$i].numberOfProductionsFiles + " files." `
            ) "ERROR"
            exit-gracefully(105);
        }
        elseif ( $sessionInImageData.status.Trim() -ne $statusToDelete.Trim() ) {
            logToFile $LOG_ROOT $("The session status " + $sessionInImageData.sessionNumber + " is different of " + $statusToDelete `
            + "`nThis session will not be deleted from Imagedata!" `
            ) "ERROR"
            exit-gracefully(105);            
        }
        else { ## steps above are fine, then delete!
            logToFile $LOG_ROOT $("Removing " + $sessionInImageData.path + "\" + $sessionInImageData.folder + " from imagedata.") "INFO"
            Remove-Item $($sessionInImageData.path + "\" + $sessionInImageData.folder) -Force -Recurse;

            ## If remove from imagedata, update status on MyStratus
            if (!(Test-path -Path $($sessionInImageData.path + "\" + $sessionInImageData.folder))) {
                logToFile $LOG_ROOT $($sessionInImageData.path + "\" + $sessionInImageData.folder + " DELETED! Updating My Stratus session status...") "INFO"                
                updateMyStratusSessionStatus $sessionInImageData.sessionNumber $statusPosDelete $archiveName
            }
        }
    }
    catch {
        logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
    }

}



