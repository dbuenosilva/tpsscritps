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
#where to look for the folders

#=================================
#==========================
#=====================
#==============
#==========
#also don't forget to comment out the  move command below: line 43.
$lookup_folder = 'Z:\0_CLIENT FOLDER\01_ARCHIVE PENDING'


$dir = Get-Filename "Y:\"   # this function is about letting the user select the file containing list of folders
$folders = get-content $dir  #this function reads the file containing the folders list and stores in $dir as an array
$file = Split-path $dir -leaf  #extract the name of the file from the directory location.

 for($i=0;$i -lt $folders.length -1;$i++)   #loop until the length of the array.
 {
 
 
 
    echo " "
    if(Test-Path $($lookup_folder + $($folders[$i]+"***")))
    {
        $found = Get-ChildItem $lookup_folder $($folders[$i]+"***")
        echo $("found: " +$found.name)
        echo " "
        Add-Content $('Z:\Arpan Adhikari Working Folder\Found_'+ $file)  $found -Encoding ASCII   #write found
        
        ######
        # this line will move the found folders to a new location
         #           mv $($lookup_folder + $found) 'Z:\0_CLIENT FOLDER\01_ARCHIVE PENDING'
        #####
    }
    else
    {
        echo $("not found: " +$found.name)
        echo " "
        Add-Content $('Z:\Arpan Adhikari Working Folder\not_Found_'+ $file)  $folders[$i] -Encoding ASCII  #write not-found
    }
 }
 
echo $folders.length
echo 'done processing'