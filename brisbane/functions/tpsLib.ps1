



# importing classes
. C:\workspace\scripts\brisbane\classes\Session.ps1




<##########################################################################
# Project: TPS Library
# Function: xit-gracefully
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
   write-logfile($("                      xxxxxxxx !!x> an exception occured. Exiting gracefully. Internal error code: " + $exit_code))
   Write-Output "error " $exit_code
   exit $exit_code
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
# type        - Type of Log. Convention values: WARNING, ERROR, INFO, SUCESS
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
    exit exit-gracefully(102);
}
catch {
    logToFile $LOG_ROOT $("Unknown error") "ERROR" -exceptionObj $_ 
}

if ($exceptionObj) {
    $errormsg = $exceptionObj.ToString()
    $positionmsg = $exceptionObj.InvocationInfo.PositionMessage
    $exception = $exceptionObj.Exception.message
 #   $stacktrace = $exceptionObj.ScriptStackTrace
 #   $failingline = $exceptionObj.InvocationInfo.Line
 #   $pscommandpath = $exceptionObj.InvocationInfo.PSCommandPath
 #   $failinglinenumber = $exceptionObj.InvocationInfo.ScriptLineNumber
#    $scriptname = $exceptionObj.InvocationInfo.ScriptName

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
# File: getMystratusSessionStatus
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

    if ($directoryToSearch) {
        $SMD_ROOT = $directoryToSearch
    }

    if ($logFile) {
        $LOG_FILE = $logFile  
    }
    else {
        $LOG_FILE = $PSScriptRoot
    }

    logToFile $LOG_FILE "Called for getMystratusSessionStatus function"
    
    $api_url = "https://api.thephotostudio.com.au/sp/Session?action=sessionnumber&value="
    $Headers = @{"x-api-key" = "1zpqpC9Gk57wCXVB46UKkv4sWFRzxc99jRz9RND8" }
    $sessionToReturn = @()

    ## Retrieving list of directories
    Try {
        $sessions = Get-ChildItem $SMD_ROOT 
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
            logToFile $LOG_FILE ("Querying session: " + $sessionName)

            $session = $null;

            try {
                $session_data = Invoke-RestMethod -Uri $($api_url + $sessionName ) -Headers $Headers
                logToFile $LOG_FILE ("Session Status: " + $session_data.StatusDescription)        

                $session = [Session]::new()
                $session.sessionNumber = $sessionName
                $session.status = $session_data.StatusDescription
                $session.path   = $sessions[$i].FullName  
                $session.folder = $sessions[$i].Name
                $session.numberOfEditsFiles       = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Edits") -Recurse -File | Measure-Object).Count
                $session.numberOfProductionsFiles = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Productions") -Recurse -File | Measure-Object).Count
                $session.numberOfSelectsFiles     = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Selects") -Recurse -File | Measure-Object).Count
                $session.numberOfUploadsFiles     = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Uploads*") -Recurse -File | Measure-Object).Count
                $session.numberOfWorkingFiles     = (Get-ChildItem $($sessions[$i].FullName + "\" +$sessionName + "_Working") -Recurse -File | Measure-Object).Count
                $session.statisticsDate           = (Get-Date)
            }
            catch [System.Net.WebException] {
                logToFile $LOG_FILE $("Session " + $sessionName + " not found ") "WARNING"

                $session = [Session]::new()
                $session.sessionNumber = $sessionName 
                $session.status  = "Session not found on Stratus"
            }
            catch {
                    logToFile $LOG_ROOT $("Fail requesting session " + $result[$i].sessionNumber) "ERROR" -exceptionObj $_                 
            }
          
            if ( $session -and (! $filter -or ( $filter -and $filter.Contains($session.status)))) {
                $sessionToReturn += $session;
            }            
        }
    } 
    logToFile $LOG_FILE "End of getMystratusSessionStatus function execution..."    

    return($sessionToReturn)
}

<##########################################################################
# Project: TPS Library
# File: getSizeFolder
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
# File: getSessionArchivedInDisk
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
# File: findItemInArrayOfObjects
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
