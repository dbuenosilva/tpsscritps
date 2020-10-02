
<#

#################################################################################################

             This Script will MOVE anything that has status "Archive Pending" to 01_ARCHIVE_PENDING

#################################################################################################

WARNING: You're not authorized to open this file. Close it Immediately.

=======================================================================
=======================================================================

README: 
------
This script runs in context to the Tpsserver1.
All the locations are relative to this server. If you don't know what this server is
you probably shouldn't be reading this/ making changes to this file (BTW: Do not make any change
even if you know that tpsserver1 is). It will break the system.

If you're familiar with PS it's a fairly simple and straightforward script.

PURPOSE:
-------
It's purpose is to automat(/g)ically grab "Archive Pending" Orders from 0_Client_Folder to Archive_Pending Folder.


TROUBLESHOOTING:
---------------
>If you came here because the script wasn't working. The Execution policy was set to "Bypass" on the server.
Keep it that way. Maybe the update or something changed the execution policy.
TIP: Set-Execution Policy Bypass

>Maybe the TASK SCHEDULER in the server is disabled or has crashed?



#>


#set tolerance for max number of errors
$ERROR_THRESHOLD = 100


$FILE_SERVER = "\\galaxy.THEPHOTOSTUDIO.local\"

# should always end with a \
$LOG_ROOT = $($FILE_SERVER + "IT\AutoScripts\Logs\PowerShell\Sydney_HUNT_ARCHIVE_PENDING\")
$ORDER_ROOT = $($FILE_SERVER + "imagedata\0_CLIENT FOLDER\")
$ARCHIVE_DEST = $($FILE_SERVER + "imagedata\0_CLIENT FOLDER\01_ARCHIVE PENDING\")

$DATE = Get-Date;

if(!(Test-Path -Path $ORDER_ROOT))
{
    exit-gracefully(99)
}

#only folders with format ABC123_AA are considered valid client folders.
$SESSIONS = Get-ChildItem -Directory -Path $ORDER_ROOT -Filter *_??


if($SESSIONS.Length -lt 2)
{
    exit-gracefully(100)
}


$API_URL = "https://api.thephotostudio.com.au/sp/session?action=SessionNumber&value="

if($Env:STRATUSXAPIKEY -eq $null)
{
    exit-gracefully(101)
}

$Headers = @{
            "x-api-key"=$Env:STRATUSXAPIKEY
            }


$LOG_ROOT = $($LOG_ROOT + $DATE.Year + "\" + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +"\")

try
{
    if(!(Test-path -Path $LOG_ROOT))
    {
        New-Item -ItemType Directory $LOG_ROOT;
    }
    if(!(Test-path -Path $ARCHIVE_DEST))
    {
        New-Item -ItemType Directory $ARCHIVE_DEST;
    }
}
catch [System.IO.IOException]
{
    exit exit-gracefully(102)
}

Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("`n`n"+ $DATE + "***************************STARTED HUNTING FOR ARCHIVE PENDING ORDERS***************************   ")


$ERROR_COUNT
 for($i=0;$i -lt $SESSIONS.length;$i++)
 {
    try
    {
        $SESSION_DATA = Invoke-RestMethod -Uri $($API_URL + $SESSIONS[$i].Name.subString(0,$SESSIONS[$i].Name.IndexOf("_"))) -Headers $Headers

        if ($SESSION_DATA.StatusDescription -eq "Archive Pending")
        {
            try
            {
                Move-Item -Path $SESSIONS[$i].FullName -Destination $ARCHIVE_DEST -Force
                Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("" + $DATE + "                      ++++++++ Found and moved order: " + $SESSIONS[$i].FullName)
            }
            catch [System.IO.IOException]
            {
                Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("" + $DATE + "                      xxxxxxxx !!x> Exception cccured while moving order: " + $SESSIONS[$i].FullName)
            }
        }

    }
    catch [System.Net.WebException]
    {
        $ERROR_COUNT++
        if($ERROR_COUNT -eq $ERROR_THRESHOLD)
        {
            Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("" + $DATE + "                      xxxxxxxx !!x> reached error Threshold. Quiting Gracefully. Last checked session " + $SESSIONS[$i].Name)
        }

        Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("" + $DATE + "                      xxxxxxxx !!x> myStratus error. Could not find session: " + $SESSIONS[$i].Name)
    }
 }

 Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("`n`n"+ $DATE + "***************************FINISHED HUNTING FOR ARCHIVE PENDING ORDERS***************************   ")

Remove-Variable -ErrorAction Ignore SESSIONS, SESSION_DATA, Headers, ERROR_THRESHOLD ,ERROR_COUNT


 function exit-gracefully($exit_code)
 {
    Remove-Variable -ErrorAction Ignore SESSIONS, SESSION_DATA, Headers, ERROR_THRESHOLD ,ERROR_COUNT
    Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("`n`n"+ $DATE + "                      xxxxxxxx !!x> an exception occured. Exiting gracefully. Internal error code: " + $exit_code)
    exit $exit_code
 }