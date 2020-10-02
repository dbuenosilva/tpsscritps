<#

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
It's purpose is to automat(/g)ically grab screen res images from sydney client folder 
and send it to marketing.


TROUBLESHOOTING:
---------------
>If you came here because the script wasn't working. The Execution policy was set to "Bypass" on the server.
Keep it that way. Maybe the update or something changed the execution policy.
TIP: Set-Execution Policy Bypass

>Maybe the TASK SCHEDULER in the server is disabled or has crashed?



#>



# should always end with a 
$LOG_ROOT = "\\galaxy\IT\AutoScripts\Logs\PowerShell\Brisbane_SMD_Marketing\"
$SMD_ROOT = "\\galaxy\imagedata\02_BRISBANE_CLIENTS\INPRODUCTION\*_RETOUCH*\*_Done*\Screen Res\*.jpg";
$SMD_DEST = "E:\Dropbox\06_Retouched Images - For Marketing\"
$DATE = Get-Date;




#add year & month to the Destination URL
$SMD_DEST = $($SMD_DEST + $DATE.Year + "\" + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month))

echo $SMD_DEST

Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("`n`n"+ $DATE + "***************************START COPY TASK***************************   ")

echo "getting childitems from smd root"

$SMD = Get-ChildItem $SMD_ROOT -File | where { $_.CreationTime.Date -eq $DATE.Date };

echo "get-childitem completed."

if(!(Test-path -Path $SMD_DEST))
    {
        New-Item -ItemType Directory $SMD_DEST;
    }

echo "started for-loop"

for($i = 0;$i -lt $SMD.Length;$i++)
{
echo $("for loop: " + $i)
    $image = $SMD[$i];
    if($image.creationTime.DayOfYear -eq $SMD[2].CreationTime.DayOfYear)
    {
         echo $("Found:" + $SMD[$i].name + ": "+($SMD[$i].CreationTime.DayOfYear -eq $SMD[2].CreationTime.DayOfYear));
         Copy-Item $image $SMD_DEST -Force
         Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("" + $DATE + "                      ++++++++ Copied file: " + $image.FullName)
    }
    else
    {
        echo $("Found:" + $SMD[$i].name + ": "+($SMD[$i].CreationTime.DayOfYear -eq $SMD[2].CreationTime.DayOfYear));
        Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("" + $DATE + "             ------------ Skipped file: " + $image.FullName)
    }      
}
Add-Content $($LOG_ROOT + (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($DATE.month) +".log")  $("" + $DATE + "***************************END COPY TASK*************************** `n`n")