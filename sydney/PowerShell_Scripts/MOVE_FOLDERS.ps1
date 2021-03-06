clear
Set-ExecutionPolicy remotesigned
Function Get-Filename($directory, $title)
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFiledialog.Title = $title
    $OpenFileDialog.initialDirectory = $directory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.SelectedPath
    
    
    
    
}

$list = Get-Filename 'Y:\Arpan Adhikari Working Folder' 'Select folder list to backup'
$folders = get-content $list
if($folders.length -lt 2)
{
   move $('Y:\0_CLIENT FOLDER\'+$folders) 'Y:\0_CLIENT FOLDER\01_ARCHIVE PENDING\' 
   echo $('Moved folder: '+ $folders)
   echo ""
}
else
{
    for($i=0;$i -ne $folders.Length-1;$i++)
    {
        
        
        move $('Y:\0_CLIENT FOLDER\'+$($folders[$i])+'***') 'Y:\0_CLIENT FOLDER\01_ARCHIVE PENDING\' 
        echo $('Moved folder: '+ $folders[$i])
        echo ""
    }
}

echo 'done!!!'

