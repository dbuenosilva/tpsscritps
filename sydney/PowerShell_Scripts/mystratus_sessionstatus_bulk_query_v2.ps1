
# A WORD OF WARNING!!!!!!!! This Script WILL delete anything that has status "Archived & Purged."
# TODO: fix exception Exception calling "Substring" with "2" argument(s): "Length cannot be less than zero.
# H:\POWERSHELL_SCRIPTS\mystratus_sessionstatus_bulk_query.ps1:61 char:50

Function Get-Directory($directory)
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    #$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    #$OpenFileDialog.initialDirectory = $directory
    #$OpenFileDialog.ShowDialog() | Out-Null
    #$OpenFileDialog.filename
    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFolderDialog.ShowDialog() | Out-Null
    $OpenFolderDialog.Description = "Select a folder from which ths script should query session statuses.";
    $OpenFolderDialog.SelectedPath;
}

Function Get-DirectoryFile($directory)
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $directory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    #$OpenFolderDialog.SelectedPath;
}

$file_suffix = Get-Date -Format dd-MM-yyyy-HHmmss
$dir = Get-Directory "\\Galaxy\imagedata\Arpan Adhikari Working Folder\"

if($dir -eq "")
{
    exit 0
}

#$file = Split-path $dir -leaf
$sessions = Get-ChildItem -Directory -Path $dir -Recurse -Depth 1
#$sessions = Get-Content $dir
echo $sessions.Length
echo $sessions[1].Name;


# CHANGE THIS SETTING TO TOGGLE AUTODELETE ON AND OFF (  $true or $false )
$autodelete = $true;

$api_url = "https://api.thephotostudio.com.au/sp/session?action=SessionNumber&value="

echo "Starting myStratus Session Status Live-Query"

$Headers = @{
            "x-api-key"="1zpqpC9Gk57wCXVB46UKkv4sWFRzxc99jRz9RND8"
            }


 for($i=0;$i -lt $sessions.length;$i++)
 {
    echo "====="
    Write-Host $("Querying session: " + $sessions[$i].Name)
    try
    {
        $session_data = Invoke-RestMethod -Uri $($api_url + $sessions[$i].Name.subString(0,$sessions[$i].Name.IndexOf("_"))) -Headers $Headers
        write-host $("   Session Status: " + $session_data.StatusDescription);
        write-host $(" Session Notes: " + $session_data.Notes);
        Add-Content $('\\Galaxy\it\Arpan Adhikari Working Folder\Session_Status_Report_'+ $file + $file_suffix + ".csv") $($sessions[$i].Name + "," + $session_data.StatusDescription.Replace(",",".") + ","+ $session_data.Notes.Replace(",","."))
        if($session_data.StatusDescription.Contains("Archived & Purged") -and $autodelete)
        {
        echo "this can be deleted";
        echo $sessions[$i].FullName;
        Remove-Item $sessions[$i].FullName -Force -Recurse;
        }

    }
    catch [System.Net.WebException]
    {
        echo $("   Session not found");
        Add-Content $('\\Galaxy\it\Arpan Adhikari Working Folder\Session_Status_Report_'+ $file + $file_suffix + ".csv") $($sessions[$i].Name + "," + "Session Not Found")
    }
 }
