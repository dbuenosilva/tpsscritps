#Set-ExecutionPolicy Bypass
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
#where to look for the folders

#=================================
#==========================
#=====================
#==============
#==========
#also don't forget to comment out the  move command below: line 43.

# where to look for the folders


$dir = Get-Filename "\\Galaxy\imagedata\Arpan Adhikari Working Folder\"   # this function is about letting the user select the file containing list of folders


$lookup_folder = '\\galaxy\imagedata\'   #this link should end with a '\'

$folders = Get-ChildItem $lookup_folder -Recurse -Directory

$orders = get-content $dir  #this function reads the file containing the folders list and stores in $dir as an array
$file = Split-path $dir -leaf  #extract the name of the file from the directory location.

echo "initial setup complete.... finding now...";
 for($i=0;$i -lt $folders.length -1;$i++)   #loop until the length of the array.
 {
    $folder = Split-Path $folders[$i].name -Leaf
    for($j=0;$j -lt $orders.Length-1;$j++)
    {
        if($folder.Contains($orders[$j]))
        {
        echo $($folder + ' = ' + $orders[$j] + " index:" + $i);
        echo $("found: " + $folders[$i].FullName);

        }
    }
 }
 
echo $folders.length
echo 'done processing'