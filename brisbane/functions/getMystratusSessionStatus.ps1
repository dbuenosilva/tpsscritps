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

function getMystratusSessionStatus { 

    param (
            [Parameter(Mandatory,
                ParameterSetName = 'directoryToSearch',
                Position = 0)]
            [string[]]$directoryToSearch,
     
            [Parameter(Mandatory,
                ParameterSetName = 'filter')]
            [string[]]$filter,
     
            [string]$logFile
        )
        $PSCmdlet.ParameterSetName        

    Write-Output $sessionToReturn

    Add-Content $($LOG_FILE) $( "" + (Get-Date) + "| START | Call for getMystratusSessionStatus function | ******************************************************   ")

    if (!$directoryToSearch){
        $SMD_ROOT = $directoryToSearch
    }

    if (!$filter){
        $FILTER = $filter
    }    

    if (!$logFile){
        $LOG_ROOT = $logFile  
    } else {
        $LOG_ROOT = "\\192.168.33.46\IT\AutoScripts\Logs\PowerShell\brisbane_archive_process\"
        $LOG_ROOT = $($LOG_ROOT + (Get-Date).Year + "\" )    
    }
    
    $api_url = "https://api.thephotostudio.com.au/sp/Session?action=sessionnumber&value="
    $Headers = @{"x-api-key" = "1zpqpC9Gk57wCXVB46UKkv4sWFRzxc99jRz9RND8" }
    $sessionToReturn =  New-Object System.Collections.ArrayList($null)

    # Evaluating LOG directory
    try {
        if (!(Test-path -Path $LOG_ROOT)) {
            New-Item -ItemType Directory $LOG_ROOT;
        }
    }
    catch [System.IO.IOException] {
        Add-Content $($LOG_FILE)  $(  "" + (Get-Date) + "| ERROR | evaluanting LOG directory! ")    
        exit exit-gracefully(102)
    }

    # Evaluating LOG file
    $LOG_FILE = $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName((Get-Date).month) + ".log")
    try {
        if (!(Test-path $LOG_FILE -PathType Leaf)) {
            New-Item -ItemType File $LOG_FILE;
        }
    }
    catch [System.IO.IOException] {
        Add-Content $($LOG_FILE)  $(  "" + (Get-Date) + "| ERROR | evaluanting LOG file! ")        
        exit exit-gracefully(102)
    }

    Add-Content $($LOG_FILE) $( "" + (Get-Date) + "| START | GET SESSION STATUS TASK | ******************************************************   ")

    ## Retrieving list of directories
    Try {
        $sessions = Get-ChildItem $SMD_ROOT 
        Write-Output $sessions.Length    
    }
    catch [System.Exception] {
        Add-Content $($LOG_FILE)  $(  "" + (Get-Date) + "| ERROR | Could not get list of directories. Get-ChildItem failed execution! ")
    }

    for ($i = 0; $i -lt $sessions.length; $i++) {

        if ( $sessions[$i].PSIsContainer ) {

            $sessionName = $sessions[$i].Name.Substring(0, $sessions[$i].Name.IndexOf('_'))
            Write-Output $("Querying session: " + $sessionName)
            try {
                $session_data = Invoke-RestMethod -Uri $($api_url + $sessionName ) -Headers $Headers
                Write-Output $("   Session Status: " + $session_data.StatusDescription);

                $sessionStatus = [SessionStatus]::new()
                $sessionStatus.Session = $sessionName 
                $sessionStatus.Status = $session_data.StatusDescription
            
                $sessionToReturn.Add($sessionStatus);

            }
            catch [System.Net.WebException] {
                Add-Content $($LOG_FILE) $( "" + (Get-Date) + "| ERROR | Session " + $sessionName + " not found ")
            }
        }
    } 
    Add-Content $($LOG_FILE) $( "" + (Get-Date) + "| END | Call for getMystratusSessionStatus function | ******************************************************   ")

    return($sessionToReturn)
}