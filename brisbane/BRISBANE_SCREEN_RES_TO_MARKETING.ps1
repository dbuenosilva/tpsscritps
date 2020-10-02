<#

WARNING: You're not authorized to open this file. Close it Immediately.
=======================================================================
=======================================================================

README: 
------
This script runs in context to the BRANON.
All the locations are relative to this server. If you don't know what this server is
you probably shouldn't be reading this/ making changes to this file (BTW: Do not make any change
even if you know that BRANON is). It will stop the backup process.

If you're familiar with PS it's a fairly simple and straightforward script.

PURPOSE:
-------
It's purpose is to automat(/g)ically grab screen res images from brisbane client folder 
and send it to External HD backup.


TROUBLESHOOTING:
---------------
>If you came here because the script wasn't working. The Execution policy was set to "Bypass" on the server.
Keep it that way. Maybe the update or something changed the execution policy.
TIP: Set-Execution Policy Bypass

>Maybe the TASK SCHEDULER in the server is disabled or has crashed?
#>


$SMD_ROOT = "C:\01_CLIENT_FOLDER\*_??\*_Edits\*.jpg" #"\\axion\imagedata\01_CLIENT_FOLDER\*_??\*_Edits\*.jpg"
$SMD_DEST = "C:\EDIT_BACKUPS\" ## testing Diego PC
$DATE = Get-Date;
$LOG_ROOT = "\\axion\IT\AutoScripts\Logs\PowerShell\brisbane_edits_backup\"
$LOG_ROOT = $($LOG_ROOT + $DATE.Year + "\" )
try {
    if(!(Test-path -Path $LOG_ROOT)) {
        New-Item -ItemType Directory $LOG_ROOT;
    }
}
catch [System.IO.IOException] {
    exit exit-gracefully(102)
}

$LOG_FILE = $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) + ".log")
try {
    if(!(Test-path $LOG_FILE -PathType Leaf)) {
        New-Item -ItemType File $LOG_FILE;
    }
}
catch [System.IO.IOException] {
    exit exit-gracefully(102)
}

#add year & month to the Destination URL
$SMD_DEST = $($SMD_DEST + $DATE.Year + "\" + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month))

Add-Content $($LOG_FILE) $( "" + $DATE + "| ***************************START COPY TASK***************************   ")

Try{
    $SMD = Get-ChildItem $SMD_ROOT ## -File | where { $_.CreationTime.Date -eq $DATE.Date }; ## for the first run copy all folders
}catch [System.Exception]{
    Add-Content $($LOG_FILE)  $(  "" + $DATE + "| ERROR Get-ChildItem execution! ")
}

if(!(Test-path -Path $SMD_DEST))
    {
        Add-Content $($LOG_FILE ) $(   "" + $DATE + "| Directory " + $SMD_DEST + " does not exist! Creating...")
        New-Item -ItemType Directory $SMD_DEST;
    }

for($i = 0;$i -lt $SMD.Length;$i++)
{
    $image = $SMD[$i];
    if($image.creationTime.DayOfYear -gt 1)
    {
         #echo $("Found:" + $SMD[$i].name + ": "+($SMD[$i].CreationTime.DayOfYear -gt 182));
         Copy-Item $image $SMD_DEST -Force
         Add-Content $($LOG_FILE ) $("" + $DATE + "| Copied file: " + $image.FullName)
    }
    else
    {
        #echo $("Found:" + $SMD[$i].name + ": "+($SMD[$i].CreationTime.DayOfYear -gt 182));
        Add-Content $($LOG_FILE ) $( "" + $DATE + "| Skipped file: " + $image.FullName)
    }      
}
Add-Content $($LOG_FILE ) $( "" + $DATE + "|***************************END COPY TASK***************************")