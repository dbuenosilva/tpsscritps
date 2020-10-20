<##########################################################################
# Project: Backup
# File: 03_delete_from_imagedata_and_update_mystratus.ps1
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 19/10/2020
# Description: Delete files archived in external HD and update session
#              status on My Stratus
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
$externalHD   = "H:\Archives"
$filter = "Archive Pending";


logToFile $LOG_ROOT "Retrieving sessions from External HardDrive"
#$archive = $(getSessionArchivedInDisk $externalHD $LOG_ROOT)

try {
    $session = getMystratusSession "400172910STE" $imageData "400172910STE_TV" $LOG_ROOT
    # Remove-Item $sessions[$i].FullName -Force -Recurse;

    ## testing if remove from imagedata
    ## if removed {
    #       updateMyStratusSessionStatus "20048555ADH" "Secondary Archive Pending" "Archived to FINDING NEMO 3"
    #  }
}
catch {
    logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
}

$debug = $session;



