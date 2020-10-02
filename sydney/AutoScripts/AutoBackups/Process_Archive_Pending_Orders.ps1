<#

#################################################################################################

             This Script will Delete any Uploads Folder from a client folder if it has Selects

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
This Script will Delete any UPloads Folder from a client folder if it has Selects. It is supposed to run on the 
Archive Pending folder.

TROUBLESHOOTING:
---------------
>If you came here because the script wasn't working. The Execution policy was set to "Bypass" on the server.
Keep it that way. Maybe the update or something changed the execution policy.
TIP: Set-Execution Policy Bypass

>Maybe the TASK SCHEDULER in the server is disabled or has crashed?


#>

$FILE_SERVER = "\\galaxy.THEPHOTOSTUDIO.local\"
$ARCHIVE_PENDING_READY_ROOT = $($FILE_SERVER + "Imagedata\0_CLIENT FOLDER\01_ARCHIVE PENDING\READY\")
$LOG_ROOT = $($FILE_SERVER + "IT\AutoScripts\Logs\PowerShell\ARCHIVE_ORDERS_FROM_ARCHIVE_PENDING\")
$ARCHIVE_DESTINATION
$ERROR_THRESHOLD = 10
$ERROR_COUNT = 0

$DATE = Get-Date

function exit-gracefully($exit_code)
{
   Remove-Variable -ErrorAction Ignore SESSIONS, SESSION_DATA, Headers, ERROR_THRESHOLD ,ERROR_COUNT
   write-logfile($("                      xxxxxxxx !!x> an exception occured. Exiting gracefully. Internal error code: " + $exit_code))
   echo "error " $exit_code
   exit $exit_code
}
function write-logfile
{
Param($LogMessage)
    $DATE = Get-Date
    Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $( $DATE.ToString() + $LogMessage)
}

try
{
    if(!(Test-path -Path $LOG_ROOT))
    {
        New-Item -ItemType Directory $LOG_ROOT;
    }
}
catch [System.IO.IOException]
{
    exit(98)
}

write-logfile -LogMessage "`n`n                     ###################### STARTED HUNTING FOR ARCHIVE PENDING ORDERS TO BACKUP ######################"


Function Get-Filename($directory)
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $directory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    
}

Function Get-Directory($directory)
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFolderDialog.ShowDialog() | Out-Null
    $OpenFolderDialog.Description = "Select Destination Folder";
    $OpenFolderDialog.SelectedPath;
}


$ARCHIVE_DESTINATION = "F:\Sydney\"

if($ARCHIVE_DESTINATION -ne "")
{
    if(!(Test-Path($ARCHIVE_DESTINATION)))
    {
        exit-gracefully(103)
    }
}
else
{
    exit-gracefully(104)
}

if($Env:STRATUSXAPIKEY -eq $null)
{
    exit-gracefully(101)
}

Copy-Item "\\galaxy.THEPHoTOSTUDIO.local\IT\AutoScripts\AutoBackups\StudioPlus.Stratus.API.Wrapper.dll" -Force -ErrorAction SilentlyContinue -Destination $env:APPDATA
copy-item "\\galaxy.THEPHoTOSTUDIO.local\IT\AutoScripts\AutoBackups\Newtonsoft.Json.dll" -Force -ErrorAction SilentlyContinue -Destination $env:APPDATA
try
{    
    add-type -LiteralPath "$env:APPDATA\StudioPlus.Stratus.API.Wrapper.dll" -PassThru
    #add-type -LiteralPath "$env:APPDATA\StudioPlus.Stratus.API.Wrapper.dll" -PassThru
    $APICLIENT= New-Object StudioPlus.Stratus.API.Wrapper.ApiClient("46546546546546","$Env:STRATUSXAPIKEY","https://api.thephotostudio.com.au/sp")
}
catch [System.IO.IOException]
{
    write-logfile "          Couldn not initialize StudioPlus.Stratus.API.Wrapper."
    exit-gracefully(105)
}

write-logfile('           Preflight Check Passed.')

write-logfile('           Starting ARCHIVING ORDER')

$ORDERS = Get-ChildItem $ARCHIVE_PENDING_READY_ROOT -Filter *_* -Directory
echo $ORDERS.Length


foreach ($ORDER in $ORDERS)   #loop until the length of the array.
{
    try
    {
        $SESSION = $APICLIENT.GetSessionByNumber($ORDER.Name.subString(0,$ORDER.Name.IndexOf("_")))
        echo $SESSION.StatusDescription

        if ($SESSION.StatusDescription -eq "Archive Pending")
        {
            try
            {
                Move-Item -Path $ORDER.FullName -Destination $($ARCHIVE_DESTINATION + $ORDER.Name ) -Force
                write-logfile $("                      ++++++++ Found and moved order: " + $ORDER.FullName)
                try
                {
                    $SESSION.Notes = "Archived to Toy Story 30"
                    $SESSION.StatusKey = "00-000-10058"
                    $APICLIENT.PutSession($SESSION)
                }
                catch
                {
                    write-logfile $("                      --[MANUAL UPDATE NOTICE]-- !!!!!!!!!!!!!! Couldn't update this order. Please update manually: " + $ORDER.FullName)
                }
            }
            catch [System.IO.IOException]
            {
                write-logfile $("" + $DATE + "                      xxxxxxxx !!x> Exception cccured while moving order: " + $ORDER.FullName)
            }
        }

    }
    catch [System.Net.WebException]
    {
        $ERROR_COUNT++
        if($ERROR_COUNT -eq $ERROR_THRESHOLD)
        {
            write-logfile $("                      xxxxxxxx !!x> reached error Threshold. Quiting Gracefully. Last checked session " + $ORDER.Name)
            exit-gracefully(106)
        }

        write-logfile $("" + $DATE + "                      xxxxxxxx !!x> myStratus error. Could not find session: " + $ORDER.Name)
    }

 }

 write-logfile ("                     FINISHED ARCHIVING              ")
