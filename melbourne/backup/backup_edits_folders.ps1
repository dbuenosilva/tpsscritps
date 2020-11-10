<##########################################################################
# Project: Backup
# File: backup_edits_folders.ps1
# Author: Diego Bueno - diego@thephotostudio.com.au
# Date: 02/10/2020
# Description: Copy files JPG from EDIT folders to external Hard Drive                
#
##########################################################################
# Maintenance                            
# Author:                                
# Date:                                                              
# Description:            
#
##########################################################################
WARNING: You're not authorized to open this file. Close it Immediately.
##########################################################################

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

# importing classes and functions
. C:\workspace\scripts\lib\tpsLib.ps1

$SMD_ROOT = "\\192.168.17.42\imagedata\01_CLIENT_FOLDER\*_??\*_Edits\*.jpg" 
$SMD_DEST = "F:\EDIT_BACKUPS\" ## external HD
$LOG_ROOT = "\\192.168.17.42\IT\AutoScripts\Logs\PowerShell\melbourne-edits-backup\"

logToFile $LOG_ROOT $("STARTING COPY EDIT_FOLDER TASK ***************************") "INFO"

# Evaluating External HD attached
try {
    if (!(Test-path $SMD_DEST -PathType Container)) {

        $SMD_DEST = "D:\EDIT_BACKUPS\" ## external HD 2

        if (!(Test-path $SMD_DEST -PathType Container)) {
            $SMD_DEST = "F:\EDIT_BACKUPS\" ## external HD 1

            if (!(Test-path $SMD_DEST -PathType Container)) {
                logToFile $LOG_ROOT $("External HD not found! ") "ERROR"
                exit exit-gracefully(102)
            }
        }
    }
}
catch [System.IO.IOException] {
    logToFile $LOG_ROOT $("Error evaluanting connected External HD! ") "ERROR" -exceptionObj $_   
    exit exit-gracefully(102)
}
catch {
    logToFile $LOG_ROOT $("Unknown error! ") "ERROR" -exceptionObj $_   
    exit exit-gracefully(102)
}

Try {
    $SMD = Get-ChildItem $SMD_ROOT 
}
catch [System.Exception] {
    logToFile $LOG_ROOT $("Could not get list of directories. Get-ChildItem failed execution! ") "ERROR" -exceptionObj $_
}
catch {
    logToFile $LOG_ROOT $("Unknown error! ") "ERROR" -exceptionObj $_   
    exit exit-gracefully(102)
}

for ($i = 0; $i -lt $SMD.Length; $i++) {
    $image = $SMD[$i];

    ## Creating EDIT_ folder
    Try { 
        $SMD_DEST_EDIT = $SMD_DEST + "\" + $image.Directory.Name 
        if ( ! (Test-path -Path $SMD_DEST_EDIT ) ) {
            New-Item -ItemType Directory $SMD_DEST_EDIT
        }
    }
    catch [System.Exception] {
        logToFile $LOG_ROOT $("Failed to create album edit folder for " + $image.FullName) "ERROR" -exceptionObj $_            
        continue
    }
    catch {
        logToFile $LOG_ROOT $("Unknown error! ") "ERROR" -exceptionObj $_   
        continue
    }    

    ## Checking if file exist
    if (Test-path ($SMD_DEST_EDIT + "\" + $image.Name) -PathType Leaf) {
        ## Comparing version of files
        if ( $image.LastWriteTimeUtc -eq (Get-ItemProperty -Path ($SMD_DEST_EDIT + "\" + $image.Name)).LastWriteTimeUtc ) {
          ##no longer need to log it
            continue         
        } 
        else {
            ## Copy keeping both files
            Try { 
                $DestinationFile = $SMD_DEST_EDIT + "\" + $image.BaseName + "_" + $image.LastWriteTime.Year + $image.LastWriteTime.Month + $image.LastWriteTime.Day + ".jpg"
                Copy-Item $image -Destination $DestinationFile -Force
                logToFile $LOG_ROOT $("Re-copied file: " + $image.FullName) "INFO"
            }
            catch [System.Exception] {
                logToFile $LOG_ROOT $("Failed to re-copy file " + $image.FullName) "ERROR" -exceptionObj $_                            
                continue
            }
            catch {
                logToFile $LOG_ROOT $("Unknown error! ") "ERROR" -exceptionObj $_   
                continue
            }  
        }
    }
    else { 
        ## Copying a new file
        Try { 
            Copy-Item $image $SMD_DEST_EDIT -Force
            logToFile $LOG_ROOT $("Copied file " + $image.FullName) "INFO" 
        }
        catch [System.Exception] {
            logToFile $LOG_ROOT $("Failed to copy file " + $image.FullName) "ERROR" -exceptionObj $_
            continue
        }            
    }    
}

try {
    Mountvol D: /D
}
catch {

}

logToFile $LOG_ROOT $("END COPY EDIT_FOLDER TASK ***************************") "INFO"