﻿
<#

#################################################################################################

             This Script will create Proselect Albums from Edits folder that contain jpegs.

#################################################################################################

WARNING: You're not authorized to open this file. Close it Immediately.

=======================================================================
=======================================================================

README: 
------
This script runs in context to the Pulsar.
All the locations are relative to this server. If you don't know what this server is
you probably shouldn't be reading this/ making changes to this file (BTW: Do not make any change
even if you know that tpsserver1 is). It will break the system.

If you're familiar with PS it's a fairly simple and straightforward script.

PURPOSE:
-------
This Script will create Proselect Albums from Edits folder that contain jpegs.

TROUBLESHOOTING:
---------------
>If you came here because the script wasn't working. The Execution policy was set to "Bypass" on the server.
Keep it that way. Maybe the update or something changed the execution policy.
TIP: Set-Execution Policy Bypass

>Maybe the TASK SCHEDULER in the server is disabled or has crashed?



#>

 #function wait-forprocess adopted from https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/waiting-for-process-launch
function Wait-ProSelect
{
    param
    (
        $Name = 'ProSelect'
    )
    #loop until process has enough handles to qualify as being "ready"
    while($true)
    {
        $p = Get-Process $Name
        if($p.Handles -gt 490)
        {
        Write-Host "app is ready"
            break;
        }
        Start-Sleep -Seconds 2
    }
}


#set tolerance for max number of errors
$ERROR_THRESHOLD = 2


$FILE_SERVER = "\\galaxy.THEPHOTOSTUDIO.local\"
$DROPBOX_ALBUMS_FOLDER = "E:\Dropbox\CLIENT_VIEWING_IMAGES\Albums\Sydney\New folder"
# should always end with a \
$LOG_ROOT = $($FILE_SERVER + "IT\AutoScripts\Logs\PowerShell\Create_Ps_Albums\")
$ORDER_ROOT = $($FILE_SERVER + "imagedata\0_CLIENT FOLDER\")

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


$LOG_ROOT = $($LOG_ROOT + $DATE.Year + "\" + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +"\")

try
{
    if(!(Test-path -Path $LOG_ROOT))
    {
        New-Item -ItemType Directory $LOG_ROOT;
    }

}
catch [System.IO.IOException]
{
    exit exit-gracefully(102)
}

Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")`
  $("`n`n"+ $DATE + "***************************STARTED CREATING PROSELECT ALBUMS***************************   ")

  #exit 0

$proselect = Get-Process "ProSelect" -ErrorAction SilentlyContinue
if($proselect)
{
    Write-Host "program running"

}
else
{
    Write-Host "program not running"
    Start-Process -FilePath "C:\Program Files (x86)\TimeExposure\ProSelect\ProSelect.exe"
    Wait-ProSelect
}


$ERROR_COUNT
foreach ($session in $SESSIONS)
{
    #Write-Host $session.FullName
    if(Test-Path $($session.FullName +"\" + $session.Name.Split('_')[0] +"_Edits"))
    {
        if((Get-ChildItem -Filter "*.psa" $($session.FullName +"\" + $session.Name.Split('_')[0] +"_Edits"))  -ne $null )
        {
            #Write-Host "Album Exists For: " $session.FullName
        }
        else
        {
            Write-Host "No Album Found For " $session.FullName
            if(($DATE - $session.LastWriteTime).TotalHours -gt 2)
            {
                $album_images = Get-ChildItem -Filter "*.jpg" $($session.FullName +"\" + $session.Name.Split('_')[0] +"_Edits") -File | where Length -lt 30mb
                if($album_images.Count -gt 10 )
                {
                    try
                    {

                    
                        Write-Host "Eligible"
                        C:\PSConsole\PSConsole.exe newAlbum saveChanges='false'
                        foreach($album_image in $album_images)
                        {
                            C:\PSConsole\PSConsole.exe addImage $album_image.FullName
                        }
                        #C:\PSConsole\PSConsole.exe addImageFolder $($session.FullName +"\" + $session.Name.Split('_')[0] +"_Edits")
                        C:\PSConsole\PSConsole.exe saveAlbumAs $($session.FullName +"\" + $session.Name.Split('_')[0] +"_Edits" + "\" + $session.Name + ' Auto Album.psa')
                        Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")`
  $(""+ $DATE + "CREATED ALBUM FOR " + $session.Name)
                        Copy-Item $($session.FullName +"\" + $session.Name.Split('_')[0] +"_Edits" + "\" + $session.Name + ' Auto Album.psa') -Destination $DROPBOX_ALBUMS_FOLDER
                    }
                    catch
                    {
                        Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")`
  $(""+ $DATE + "Couldn't Create Album For: " + $session.Name)
                    }
                 }
            }
            else
            {
                Write-Host "Not Eligible"
            }
        }
    }

}



Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")`
  $("`n`n"+ $DATE + "***************************FINISHED CREATING PROSELECT ALBUMS***************************   ")

Remove-Variable -ErrorAction Ignore SESSIONS, ERROR_THRESHOLD ,ERROR_COUNT


 function exit-gracefully($exit_code)
 {
    Remove-Variable -ErrorAction Ignore SESSIONS, ERROR_THRESHOLD ,ERROR_COUNT
    Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")`
      $("`n`n"+ $DATE + "                      xxxxxxxx !!x> an exception occured. Exiting gracefully. Internal error code: " + $exit_code)
    
    exit $exit_code
 }