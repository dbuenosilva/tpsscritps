



# importing classes
. C:\workspace\scripts\brisbane\classes\Session.ps1




<##########################################################################
# Project: TPS Library
# Function: Exit-gracefully
# Author: Arpan - arpan@thephotostudio.com.au
# Date: 14/10/2020
# Description: Exit a program
#
# Parameters: 
# exit_code - ??  
# Return:
# Null
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>
function exit-gracefully($exit_code)
{
   Remove-Variable -ErrorAction Ignore SESSIONS, SESSION_DATA, Headers, ERROR_THRESHOLD ,ERROR_COUNT
   logToFile $LOG_ROOT $("xxxxxxxx !!x> an exception occured. Exiting gracefully. Internal error code: " + $exit_code) "ERROR"
   exit $exit_code
}

<##########################################################################
# Project: TPS Library
# Function: Get-Filename
# Author: Arpan - arpan@thephotostudio.com.au
# Date: 14/10/2020
# Description: Exit a program
#
# Parameters: 
# directory - 
# Return:
# Null
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

Function Get-Filename($directory)
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $directory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    
}

<##########################################################################
# Project: TPS Library
# Function: logToFile
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 14/10/2020
# Description: Log messages to month file splitting directory by year
#
# Parameters: 
# folderToLog - Folder to create year directory and month file log.              
# message     - Message to write
# type        - Type of Log. Convention values: WARNING, ERROR, INFO, SUCCESS
# Return:
# Null
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

function logToFile {

    Param(
        [parameter(Mandatory=$true)]
        [String]
        $folderToLog,
        [parameter(Mandatory=$true)]
        [String]
        $message,
        [parameter(Mandatory=$false)]
        [String]
        $type = "INFO",
        [parameter(Mandatory=$false)]
        [Object]
        $exceptionObj
        )    

$folderToLog = $($folderToLog + (Get-Date).Year + "\" );
$fileToLog   = "";

# Evaluating LOG directory
try {
    if (!(Test-path -Path $folderToLog)) {
        New-Item -ItemType Directory $folderToLog;
    }
}
catch [System.IO.IOException] {
    Write-Output $(  "" + (Get-Date) + " ERROR evaluanting LOG directory " + $folderToLog);
    exit exit-gracefully(102);
}
catch {
    logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
}    

# Evaluating LOG file
$fileToLog = $($folderToLog + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName((Get-Date).month) + ".log");
try {
    if (!(Test-path $fileToLog -PathType Leaf)) {
        New-Item -ItemType File $fileToLog;
    }
}
catch [System.IO.IOException] {
    Write-Output $(  "" + (Get-Date) + " ERROR evaluanting LOG file " + $fileToLog)        
    exit-gracefully(102);
}
catch {
    logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
}

if ($exceptionObj) {
    
    $positionmsg = $exceptionObj.InvocationInfo.PositionMessage
    $exception = $exceptionObj.Exception.message
 #   $errormsg = $exceptionObj.ToString()    
 #   $stacktrace = $exceptionObj.ScriptStackTrace
 #   $failingline = $exceptionObj.InvocationInfo.Line
 #   $pscommandpath = $exceptionObj.InvocationInfo.PSCommandPath
 #   $failinglinenumber = $exceptionObj.InvocationInfo.ScriptLineNumber
 #   $scriptname = $exceptionObj.InvocationInfo.ScriptName

   $message +=  " `n" + "ERROR details: " + $exception + " `n" + $positionmsg

   ## NEED TO SEND EMAIL HERE   

}


#Add-Content does not work with another program reading the log simutaneously, change to Out-File
#Add-Content $fileToLog  $( "" + (Get-Date) + "|" + $type + "|" + $message);
$logstring = $( "" + (Get-Date) + "|" + $type + "|" + $message);
$logstring | Out-File $fileToLog -Append 

}


<##########################################################################
# Project: TPS Library
# Function: getMystratusSession
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 20/10/2020
# Description: Get session details of specific session
#
# Parameters: 
# sessionToSearch - Directory to search a valid sessions           
# path - Path to evaluate files
# folder - Folder to evaluate files
# logFile - log File
#
# Return:
# sessionToReturn - array with Session objects
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:
#
##########################################################################>

function getMystratusSession { 

    Param(
        [parameter(Mandatory = $true)]
        [String]
        $sessionToSearch,
        [parameter(Mandatory = $true)]
        [String]
        $path,
        [parameter(Mandatory = $true)]
        [String]
        $folder,        
        [parameter(Mandatory = $false)]
        [String]
        $logFile
    )    

    if ($logFile) {
        $LOG_FILE = $logFile
    }

    logToFile $LOG_FILE "Called for getMystratusSession function"
    
    $api_url = "https://api.thephotostudio.com.au/sp/Session?action=sessionnumber&value="
    $Headers = @{"x-api-key" = "1zpqpC9Gk57wCXVB46UKkv4sWFRzxc99jRz9RND8" }

    logToFile $LOG_FILE ("Querying session: " + $sessionToSearch)

    $session = $null;

    try {
        $session_data = Invoke-RestMethod -Uri $($api_url + $sessionToSearch ) -Headers $Headers
        logToFile $LOG_FILE ("Session Status: " + $session_data.StatusDescription)        

        $session = [Session]::new()
        $session.sessionNumber = $session_data.SessionNumber
        $session.status = $session_data.StatusDescription
        $session.path = $path
        $session.folder = $folder
        $notfoundMessage = " did not found for session " + $session_data.SessionNumber

        if (Test-path -Path $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Edits")) {
            $session.numberOfEditsFiles = (Get-ChildItem $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Edits") -Recurse -File | Measure-Object).Count
        }
        else {
            $session.numberOfEditsFiles = 0;
            logToFile $LOG_ROOT $("Folder " + $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Edits") `
                                + $notfoundMessage) "WARNING"
        }

        if (Test-path -Path $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Productions")) {
            $session.numberOfProductionsFiles = (Get-ChildItem $($path + "\" + $folder + "\" + $session_data.SessionNumberh + "_Productions") -Recurse -File | Measure-Object).Count
        }
        else {
            $session.numberOfProductionsFiles = 0;
            logToFile $LOG_ROOT $("Folder " + $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Productions") `
                                + $notfoundMessage) "WARNING"
        }            

        if (Test-path -Path $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Selects")) {
            $session.numberOfSelectsFiles = (Get-ChildItem $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Selects") -Recurse -File | Measure-Object).Count
        }
        else {
            $session.numberOfSelectsFiles = 0;
            logToFile $LOG_ROOT $("Folder " + $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Selects") `
                                + $notfoundMessage) "WARNING"
        }            

        if (Test-path -Path $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Uploads")) {
            $session.numberOfUploadsFiles = (Get-ChildItem $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Uploads") -Recurse -File | Measure-Object).Count
        }
        else {
            $session.numberOfUploadsFiles = 0;
            logToFile $LOG_ROOT $("Folder " + $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Uploads") `
                                + $notfoundMessage) "WARNING"
        }            

        if (Test-path -Path $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Working")) {
            $session.numberOfWorkingFiles = (Get-ChildItem $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Working") -Recurse -File | Measure-Object).Count
        }
        else {
            $session.numberOfWorkingFiles = 0;
            logToFile $LOG_ROOT $("Folder " + $($path + "\" + $folder + "\" + $session_data.SessionNumber + "_Working") `
                                + $notfoundMessage) "WARNING"
        }            
        $session.statisticsDate = (Get-Date)
    }
    catch [System.Net.WebException] {
        logToFile $LOG_FILE $("Session " + $sessionToSearch + " not found ") "WARNING"

        $session = [Session]::new()
        $session.sessionNumber = $sessionToSearch 
        $session.path = $path
        $session.folder = $folder        
        $session.status = "Session not found on Stratus"
    }
    catch [System.Management.Automation.ItemNotFoundException] { # input path not found
        logToFile $LOG_ROOT $("Fail to look into folders of session " + $sessionToSearch) "ERROR" -exceptionObj $_                 
    }     
    catch {
        logToFile $LOG_ROOT $("Fail requesting session " + $sessionToSearch) "ERROR" -exceptionObj $_                 
    }
     
    logToFile $LOG_FILE "End of getMystratusSession function execution..."    

    return($session)
}



<##########################################################################
# Project: TPS Library
# Function: getListOfMystratusSessions
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 02/10/2020
# Description: Get session status of specific directory 
#
# Parameters: 
# directoryToSearch - Directory to search valid sessions               
# logFile - log File
# filter - Filter to apply on query
#
# Return:
# sessionToReturn - array with Session objects
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

function getListOfMystratusSessions { 

    Param(
        [parameter(Mandatory = $true)]
        [String]
        $directoryToSearch,
        [parameter(Mandatory = $true)]
        [String]
        $filter,
        [parameter(Mandatory = $false)]
        [String]
        $logFile
    )    

    if ($logFile) {
        $LOG_FILE = $logFile  
    }
    else {
        $LOG_FILE = $PSScriptRoot
    }

    logToFile $LOG_FILE "Called for getListOfMystratusSessions function"
    
    $sessionToReturn = @()

    ## Retrieving list of directories
    Try {
        $sessions = Get-ChildItem $directoryToSearch 
        logToFile $LOG_FILE ("Found " + $sessions.Length + " sessions") "INFO" 
    }
    catch [System.Exception] {
        logToFile $LOG_FILE "Could not get list of directories. Get-ChildItem failed execution!" "ERROR"
    }
    catch {
        logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
    }    

    for ($i = 0; $i -lt $sessions.length; $i++) {

        if ( $sessions[$i].PSIsContainer -and $sessions[$i].Name.Contains("_") ) {

            $sessionName     = $sessions[$i].Name.Substring(0, $sessions[$i].Name.IndexOf('_'))

            if ($sessionName) {

                logToFile $LOG_FILE ("Querying session: " + $sessionName)

                $session = getMystratusSession -sessionToSearch $sessionName -path $directoryToSearch -folder $sessions[$i].Name
              
                if ( $session -and (! $filter -or ( $filter -and $filter.Contains($session.status)))) {
                    $sessionToReturn += $session;
                }            
            }
            else {
                logToFile $LOG_FILE $("Could not get session name of directory " + $sessions[$i].Name) "ERROR"
            }
        }
    } 
    logToFile $LOG_FILE "End of getListOfMystratusSessions function execution..."    

    return($sessionToReturn)
}

<##########################################################################
# Project: TPS Library
# Function: getSizeFolder
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 02/10/2020
# Description: Get the size of directory in MB
#
# Parameters: 
# pth - Path of Directory         
#
# Return:
# Size of Folder
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

function getSizeFolder
{
 param([string]$pth)
  return ("{0:n2}" -f ((Get-ChildItem -path $pth -recurse | measure-object -property length -sum).sum /1mb) )
}


<##########################################################################
# Project: TPS Library
# Function: getSessionArchivedInDisk
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 14/10/2020
# Description: Get list of directories and convert to Session data type
#
# Parameters: 
# pathOfDirectoryToSearch - Path of Directory to search
#
# Return:
# array with Session objects
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

function getSessionArchivedInDisk { 

    Param(
        [parameter(Mandatory = $true)]
        [String]
        $pathOfDirectoryToSearch,
        [parameter(Mandatory = $false)]
        [String]
        $logFile
    )    

    $sessionToReturn = @()

    if ($pathOfDirectoryToSearch) {
        $SMD_ROOT = $pathOfDirectoryToSearch
    }

    if ($logFile) {
        $LOG_FILE = $logFile  
    }
    else {
        $LOG_FILE = $PSScriptRoot
    }

    logToFile $LOG_FILE "Called for getSessionArchivedInDisk function"
    
    ## Retrieving list of directories
    Try {
        $sessions = Get-ChildItem $SMD_ROOT 
        logToFile $LOG_FILE ("Found " + $sessions.Length + " sessions") "INFO" 
    }
    catch {
        logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
    }    

    for ($i = 0; $i -lt $sessions.length; $i++) {

        if ( $sessions[$i].PSIsContainer -and $sessions[$i].Name.Contains("_") ) {

            $sessionName     = $sessions[$i].Name.Substring(0, $sessions[$i].Name.IndexOf('_'))
            logToFile $LOG_FILE ("Retrieving data from session: " + $sessionName)

            try {
                $session = [Session]::new()
                $session.sessionNumber = $sessionName
                $session.status = 'External HD'
                $session.path   = $sessions[$i].FullName  
                $session.folder = $sessions[$i].Name  
                $session.numberOfEditsFiles       = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Edits") -Recurse -File | Measure-Object).Count
                $session.numberOfProductionsFiles = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Productions") -Recurse -File | Measure-Object).Count
                $session.numberOfSelectsFiles     = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Selects") -Recurse -File | Measure-Object).Count
                $session.numberOfUploadsFiles     = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Uploads*") -Recurse -File | Measure-Object).Count
                $session.numberOfWorkingFiles     = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Working") -Recurse -File | Measure-Object).Count
                $session.statisticsDate           = (Get-Date)                
            }
            catch {
                logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
            }    
         
            $sessionToReturn += $session;
        }
    } 
    logToFile $LOG_FILE "End of getSessionArchivedInDisk function execution..."    

    return($sessionToReturn)
}



<##########################################################################
# Project: TPS Library
# Function: findItemInArrayOfObjects
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 14/10/2020
# Description: find an Item in Array Of Objects using its string
#
# Parameters: 
# itemToFind - Object to be found               
# arrayToLookIn - Array to search
#
# Return:
# position - position of array with object
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

function findItemInArrayOfObjects {

    Param(
        [parameter(Mandatory = $true)]
        [System.Object]
        $itemToFind,
        [parameter(Mandatory = $true)]
        [array]
        $arrayToLookIn
    )    

    $position = 0;

    for ($i = 0; $i -lt $arrayToLookIn.length; $i++) {
        try {
            
            if ( $arrayToLookIn[$i].ToString() -eq $itemToFind.ToString() ) {
                $position = $i;
            }

        }
        catch {
            logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
        }    
    } 

return $position 

}



<##########################################################################
# Project: TPS Library
# Function: updateMyStratusSessionStatus
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 19/10/2020
# Description: Update the status of a Session on My Stratus by API
#
# Parameters: 
# session - Session to be updated
# newStatus - The new status to be set
# notes - Notes to be added to the session
#
# Return:
# null
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

function updateMyStratusSessionStatus {

    Param(
        [parameter(Mandatory = $true)]
        [String]
        $sessionNumber,
        [parameter(Mandatory = $true)]
        [String]
        $newStatus,
        [parameter(Mandatory = $false)]
        [String]
        $newNotes
    )

    $api_url = "https://api.thephotostudio.com.au/sp/Session?action=sessionnumber&value="
    $Headers = @{"x-api-key" = "1zpqpC9Gk57wCXVB46UKkv4sWFRzxc99jRz9RND8" }
    $newStatusKey = getStatusKey($newStatus); 
    #"00-999-10130" = "Secondary Archive Pending"
    #"00-000-10058" = "Archived & Purged"  

    if (!$newStatusKey) {
        logToFile $LOG_ROOT $("New status invalid for MyStratus") "ERROR"
        exit-gracefully(105);  
    }

    # retrieving the session to My Stratus
    try
    {    
        $myStratusSession = Invoke-RestMethod -Uri $($api_url + $sessionNumber ) -Headers $Headers
        logToFile $LOG_ROOT $("Retrieved session " + $sessionNumber + " from My Stratus via API") "INFO"
    }
    catch [System.IO.IOException]
    {
        logToFile $LOG_ROOT $("Could not retrieved session " + $sessionNumber + " from My Stratus via API") "ERROR"
        exit-gracefully(105);
    }

    # updating new status 
    try {
        
        logToFile $LOG_ROOT $("Updating session " + $myStratusSession.SessionNumber + " from status " + $myStratusSession.StatusDescription `
                                + " to new status " + $newStatus)   "INFO"

        if ($myStratusSession.StatusDescription.Trim() -ne  $newStatus.Trim())
        {
            try {

                $myStratusSession.StatusKey = $newStatusKey;
                $myStratusSession.StatusDescription = $newStatus;
                $myStratusSession.Notes = $newNotes; 

                $result = Invoke-RestMethod -Method 'Put' -Uri $($api_url + $sessionNumber ) -Headers $Headers -Body $($myStratusSession | ConvertTo-Json)
  
            }
            catch [System.Net.WebException] { 

                if ($_.Exception.Response.StatusCode.value__ -ne 200) {
                    logToFile $LOG_ROOT $("Couldn't update " + $sessionNumber + " to its new status. Please update manually" `
                    + "\n Http status: " + $_.Exception.Response.StatusCode.value__ `
                    + "\n Description: " + $_.Exception.Response.StatusDescription) "ERROR"
                }
            }
            catch { 
                logToFile $LOG_ROOT $("Couldn't update " + $sessionNumber + " to its new status. Please update manually") "ERROR" -exceptionObj $_ 
            }
        }
    }
    catch {
        logToFile $LOG_ROOT $("Couldn't update " + $sessionNumber + " session status on My Stratus. Please update manually") "ERROR" -exceptionObj $_ 
    }
}



<##########################################################################
# Project: TPS Library
# Function: getStatusKey
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 19/10/2020
# Description: Update the status of a Session on My Stratus by API
#
# Parameters: 
# session - Session to be updated
# newStatus - The new status to be set
# notes - Notes to be added to the session
#
# Return:
# null
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################>

function getStatusKey() {

    Param(
        [parameter(Mandatory = $true)]
        [String]
        $searchedDescription)

    $api_url_statuses = "https://api.thephotostudio.com.au/sp/SessionStatus";
    $Headers = @{"x-api-key" = "1zpqpC9Gk57wCXVB46UKkv4sWFRzxc99jRz9RND8" };
    $statusKey = $null;

    try {
        $session_data = Invoke-RestMethod -Uri $($api_url_statuses ) -Headers $Headers
        logToFile $LOG_ROOT ("Retrieving statuses... ") "INFO"

        for ($i = 0; $i -lt $session_data.length; $i++) {
            if ($session_data[$i].Description.Trim() -eq $searchedDescription.Trim() ) {
                $statusKey = $session_data[$i].Key;
            }
        }
    }
    catch {
        logToFile $LOG_ROOT $("Couldn't retrieve list of statuses from My Stratus") "ERROR" -exceptionObj $_ 
    }
    
    return($statusKey);
}