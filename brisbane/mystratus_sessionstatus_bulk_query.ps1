Function Get-Filename($directory)
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $directory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    
}

$dir = Get-Filename "C:\archiveworks\"
$file = Split-path $dir -leaf
$sessions = Get-Content $dir
echo $sessions.Length


$api_url = "https://api.thephotostudio.com.au/sp/Session?action=sessionnumber&value="
echo " " 

$Headers = @{
            "x-api-key"="1zpqpC9Gk57wCXVB46UKkv4sWFRzxc99jRz9RND8"            }

 for($i=0;$i -lt $sessions.length -1;$i++)
 {
 echo $("Querying session: " + $sessions[$i])
 try
 {
 $session_data = Invoke-RestMethod -Uri $($api_url + $sessions[$i].Substring(0,$sessions[$i].IndexOf('_'))) -Headers $Headers
 echo $("   Session Status: " + $session_data.StatusDescription);
 Add-Content $('C:\archiveworks\Session_Status_Report_'+ $file + ".csv") $($sessions[$i] + "," + $session_data.StatusDescription)
 }
 catch [System.Net.WebException]
 {
  echo $("   Session not found");
 Add-Content $('C:\archiveworks\Session_Status_Report_'+ $file + ".csv") $($sessions[$i].Substring(0,$sessions[$i].IndexOf('_')) + "," + "Session Not Found")
 }
 }