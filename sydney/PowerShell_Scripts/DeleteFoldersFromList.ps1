Set-ExecutionPolicy remotesigned
#$list = Read-Host 'Enter the file containing the list'


#if(Test-Path $list) tests for file existance
Function Get-Filename($directory)
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $directory
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    
}

$lookup_folder = 'I:\Found as Archived and Purged 2016\'

$folderListFile = Get-Filename 'X:\'

$list_to_delete = Get-Content $folderListFile

 for($i=0;$i -lt $list_to_delete.length -1;$i++)
 {
   $foundFolder = Get-ChildItem $lookup_folder -r $list_to_delete[$i]
   if(Test-Path $foundFolder.fullname)
   {
    echo $("Found: " +$list_to_delete[$i])
    Remove-Item $foundFolder.fullname -recurse -force
    echo $("Deleted: "+ $list_to_delete[$i])
   }
  
 }
 echo $list_to_delete.length
echo 'done processing'