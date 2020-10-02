
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
$ARCHIVE_PENDING_ROOT = $($FILE_SERVER + "Imagedata\0_CLIENT FOLDER\01_ARCHIVE PENDING\")
$READY_FOR_ARCHIVAL_ROOT = $($FILE_SERVER + "Imagedata\0_CLIENT FOLDER\01_ARCHIVE PENDING\READY\" )
$LOG_ROOT = $($FILE_SERVER + "IT\AutoScripts\Logs\PowerShell\DELETE_UPLOADS_ARCHIVE_PENDING\")


$DATE = Get-Date

function exit-gracefully($exit_code)
{
   Remove-Variable -ErrorAction Ignore SESSIONS, SELECTS, UPLOAD, ORDERS, SIZE
   write-logfile($("                      xxxxxxxx !!x> an exception occured. Exiting gracefully. Internal error code: " + $exit_code))
   exit $exit_code
}

function write-logfile
{
Param($LogMessage)
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
write-logfile -LogMessage "`n`n                     ###################### STARTED HUNTING FOR UPLOADS ON ARCHIVE PENDING ORDERS ######################"

try
{
    $ORDERS = Get-ChildItem -Directory $ARCHIVE_PENDING_ROOT -Exclude "READY"
}
catch [System.IO.IOException]
{
    exit-gracefully(99)    
}

write-logfile("                     Passed Pre-flight Check ")

foreach ($ORDER in $ORDERS)
{
    $SELECT = Get-ChildItem -Directory $ORDER.FullName -Filter "*Select*"
    $SIZE = 0
    if($SELECT -eq $null)
    {
        write-logfile("                     ----------- There's no selects for this order")
    }
    else
    {
        foreach ($FILE in $SELECT.GetFiles())
        {
            # 524288000 Bytes= 500 MegaBytes
            $SIZE += $FILE.length
        }
    }
    if ($SIZE -gt 524288000)
    {
        $UPLOAD = Get-ChildItem -Path $ORDER.FullName -Filter "*Upload*"
        if($UPLOAD -ne $null)
        {
            write-logfile($("                     -----------This Uploads can be deleted. Deleting.  " + $Upload.FullName))
            try
            {
                Remove-Item -Path $UPLOAD.FullName -Recurse -Force
                write-logfile("                     done.")
                try
                {
                    Move-Item -Path $ORDER.FullName -Destination $($READY_FOR_ARCHIVAL_ROOT + $ORDER.Name) -Force
                }
                catch [System.IO.IOException]
                {
                    write-logfile( $("                     ----------- Couldn't move this order to " + $READY_FOR_ARCHIVAL_ROOT) )
                }

            }
            catch [System.IO.IOException]
            {
                write-logfile($("                     -----------Couldn't delete this  " + $UPLOAD.FullName))
            }
        }
        else
        {
            write-logfile( $("                     ----------- No Uploads Exist for this order. Skipping Deletion. Moving to READY " + $READY_FOR_ARCHIVAL_ROOT) )
            try
            {
                Move-Item -Path $ORDER.FullName -Destination $($READY_FOR_ARCHIVAL_ROOT + $ORDER.Name) -Force
            }
            catch [System.IO.IOException]
            {
                write-logfile( $("                     ----------- Couldn't move this order to " + $READY_FOR_ARCHIVAL_ROOT) )
            }
        }
     }
    else
    {
        $UPLOAD = Get-ChildItem -Path $ORDER.FullName -Filter "*Upload*"
        if($UPLOAD -eq $null)
        {
            write-logfile($("                     (!!!!!!!!!!) This Client folder has selects less than 500MB and NO Uploads: INV:"+$SELECT.Parent.Name))
            continue;
        }
        if($UPLOAD.GetFiles().Length -lt 500)
        {
            write-logfile($("                     (!!!!!!!!!!) This Client folder has selects less than 500MB and also less than 500 Images in Uploads: INV:"+$SELECT.Parent.Name))
        }

    }
}

write-logfile("`n`n                     ###################### FINISHED HUNTING FOR UPLOADS ON ARCHIVE PENDING ORDERS ######################")