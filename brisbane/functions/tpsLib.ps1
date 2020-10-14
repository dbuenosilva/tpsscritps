




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
        $type = "INFO"
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

Add-Content $fileToLog  $( "" + (Get-Date) + "|" + $type + "|" + $message);

}