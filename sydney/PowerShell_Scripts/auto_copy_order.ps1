Set-ExecutionPolicy remotesigned
$syd_folder = 'X:\0_CLIENT FOLDER\'
echo " "

# ask for the folder containing previews 
$preview_number = Read-Host -Prompt " Enter the preview folder name"

echo " ";
#ask for the folder to to copy the images to
$destination_folder = Read-Host -Prompt "Enter destination folder name eg: xyz_pp"



$files=dir $($syd_folder + $preview_number + "\Previews\")
$files_to_copy = @();
for($i=0;$i -lt $files.length;$i++)
{
    
    #$files[$i]=$files[$i].tostring().TrimEnd(".*");
    #$files[$i] -replace '_'
    
    $files_to_copy = $files_to_copy + $($files[$i].Name.Substring(0,$files[$i].Name.LastIndexOf('_'))+$files[$i].Extension);
    echo $files_to_copy[$i];

}

$production_folder = $($syd_folder + $destination_folder + "\" + $preview_number + "_Productions\" )

if(!(Test-Path $production_folder ))
{
   mkdir $production_folder;
}
if(!(Test-Path $($production_folder + $destination_folder + "_RETOUCH\" )))
{
   mkdir $($production_folder + $destination_folder + "_RETOUCH\" );
}

for($i=0; $i -lt $files_to_copy.Length; $i++)
{
    cp $($($syd_folder + $destination_folder + "\" + $preview_number + "_Edits\") + $files_to_copy[$i]) $production_folder;
    cp $($($syd_folder + $destination_folder + "\" + $preview_number + "_Edits\") + $files_to_copy[$i]) $($production_folder + $destination_folder + "_RETOUCH\") ;
}

echo $files_to_copy.Length;


