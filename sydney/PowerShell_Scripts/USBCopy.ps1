Set-ExecutionPolicy remotesigned
#$list = Read-Host 'Enter the file containing the list'


#if(Test-Path $list) tests for file existance
Function Get-Foldername($directory)
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFileDialog.ShowDialog()|Out-null
    $OpenFileDialog.selectedpath
    
    
    
    
}

$dir = Get-Foldername 'C:\'
#$folders = get-content $list

    
    #$p = @()
    #$folders[$i]
    #$found = @(Get-ChildItem 'Y:\0_CLIENT FOLDER' $folders[$i])
    #Add-Content 'Y:\Arpan Adhikari Working Folder\found list2.txt' $found.name 
    
    #Add-Content 'Y:\Arpan Adhikari Working Folder\found list.txt'  $found -Encoding ASCII
# }

echo "folder selected: " $dir
echo 'done processing'