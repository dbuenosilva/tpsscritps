#Set-ExecutionPolicy RemoteSigned
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

#sydney
$lookup_folder = '\\cadmium\backup\'   #this link should end with a '\'

#melbourne
#$lookup_folder = '\\Galaxy\imagedata\01_MELBOURNE_CLIENTS\New Clients\'

$working_folder = '\\andromeda\it\archiveworks\'


$dir = Get-Filename $working_folder   # this function is about letting the user select the file containing list of folders
$folders = get-content $dir #this function reads the file containing the folders list and stores in $dir as an array
$file = Split-path $dir -leaf  #extract the name of the file from the directory location.
echo "Getting Child-item"
$uploads = Get-childitem $lookup_folder -Directory | Select Directory,FullName,Name
echo "Finished getting child-item"

echo "looping ..."
 
 for($i=0;$i -lt $folders.length -1;$i++)   #loop until the length of the array.
 {
    foreach ($uploads_folder in $uploads )
    {
        if($uploads_folder.Name -eq $folders[$i])
        {
            echo "found" $uploads_folder.FullName;
            Add-Content $($working_folder +'Found_'+ $file)  $found #-Encoding ASCII   #write found
            #mv $($uploads_folder.FullName) '\\galaxy\Studio Uploads\TO DELETE\'
            break;
        }
        else
        {
            if(!(Test-path -Path $($working_folder + 'PSTEST\')))
            {
                New-Item -ItemType Directory $($working_folder + 'PSTEST\');
            }
            #echo $("not found: " +$folders[$i].name)
            #echo " "
            Add-Content $($working_folder + 'PSTEST\' + 'NotFound_'+ $file)  $folders[$i] #-Encoding ASCII  #write not-found
        }

    } 
    #code

    #code    
 }
 
echo $folders.length
echo 'done processing'