<##########################################################################
# Project: Backup
# File: getMystratusSessionStatus.ps1
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 02/10/2020
# Description: Get session status of specific directory 
#
# Parameters: 
# directoryToSearch - Directory to search valid sessions               
# logFile - log File
#
# Return:
# sessionToReturn - array with Session details
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

# importing classes
. C:\workspace\scripts\brisbane\classes\SessionStatus.ps1
. C:\workspace\scripts\brisbane\functions\tpsLib.ps1

function getMystratusSessionStatus { 

    Param(
        [parameter(Mandatory = $true)]
        [String]
        $directoryToSearch,
        [parameter(Mandatory = $false)]
        [String]
        $filter,
        [parameter(Mandatory = $false)]
        [String]
        $logFile
    )    

    if (!$directoryToSearch) {
        $SMD_ROOT = $directoryToSearch
    }

    if (!$filter) {
        $FILTER = $filter
    }    

    if (!$logFile) {
        $LOG_FILE = $logFile  
    }
    else {
        $LOG_FILE = "\\192.168.33.46\IT\AutoScripts\Logs\PowerShell\retrieving_stratus_status\"
    }

    logToFile $LOG_FILE "Called for getMystratusSessionStatus function | ******************************************************"
    
    $api_url = "https://api.thephotostudio.com.au/sp/Session?action=sessionnumber&value="
    $Headers = @{"x-api-key" = "1zpqpC9Gk57wCXVB46UKkv4sWFRzxc99jRz9RND8" }
    $sessionToReturn = New-Object System.Collections.ArrayList($null)

    ## Retrieving list of directories
    Try {
        $sessions = Get-ChildItem $SMD_ROOT 
        Write-Output $sessions.Length    
    }
    catch [System.Exception] {
        logToFile $LOG_FILE "Could not get list of directories. Get-ChildItem failed execution!" "ERROR"
    }

    for ($i = 0; $i -lt $sessions.length; $i++) {

        if ( $sessions[$i].PSIsContainer ) {

            $sessionName = $sessions[$i].Name.Substring(0, $sessions[$i].Name.IndexOf('_'))
            logToFile $LOG_FILE ("Querying session: " + $sessionName)
            Write-Output $("Querying session: " + $sessionName);

            try {
                $session_data = Invoke-RestMethod -Uri $($api_url + $sessionName ) -Headers $Headers
                logToFile $LOG_FILE ("Session Status: " + $session_data.StatusDescription)        
                Write-Output $("Session Status: " + $session_data.StatusDescription);              

                $sessionStatus = [SessionStatus]::new()
                $sessionStatus.Session = $sessionName 
                $sessionStatus.Status = $session_data.StatusDescription
            
                $sessionToReturn.Add($sessionStatus);

            }
            catch [System.Net.WebException] {
                logToFile $LOG_FILE ("Session " + $sessionName + " not found ") "WARNING"
                Write-Output $("Session " + $sessionName + " not found "); 
            }
        }
    } 
    logToFile $LOG_FILE "End of getMystratusSessionStatus function execution..."    

    return($sessionToReturn)
}