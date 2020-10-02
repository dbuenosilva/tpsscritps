$folders = Get-ChildItem "C:\Users\Mercury-Admin\Dropbox\03_Melbourne Jobs\"

for ($i = 0;$i -lt $folders.Length;$i++)
{
    $folder_name = $folders[$i].name;
    $retouch_folder = $($folder_name.substring(0,$folder_name.lastIndexof("_")) + "_RETOUCH\");
    $folder_fullname = $folders[$i].fullName;
    $successful_jobs = @();
    $error_jobs = @();
    $retouch_folder_fullpath = $($folder_fullname+ "\" + $retouch_folder);
    echo $retouch_folder;

   

    if(!(Test-Path $retouch_folder_fullpath))
    {
        mkdir $retouch_folder_fullpath;
        
        $files = Get-ChildItem $folder_fullname -Filter *.jpg

        for ($j = 0;$j -lt $files.Length;$j++)
        {
            cp $files[$j].FullName $retouch_folder_fullpath;
        }
        $successful_jobs = $successful_jobs + $folder_name;
    }
    else
    {
        
        $error_jobs = $error_jobs + $folder_name;
        
    }



    
}

echo " "
    echo " Successfull jobs: " $successful_jobs;


    echo " "
    echo "Error jobs:" $error_jobs