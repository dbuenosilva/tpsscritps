$list = get-childitem \\andromeda\Imagedata\01_Client_Folder\ -Directory

foreach ($order in $list)
{
    $order_folders = get-childitem $order.FullName
    
    foreach ($folder in $order_folders)
    {
        if($folder.FullName.Contains("Uploads"))
        {
            foreach($folder2 in $order_folders)
            {
                if($folder2.fullname.contains("Selects"))
                {
                    $selects = Get-ChildItem $folder2.FullName
                    if($selects.Length > 20) #check if at least 20 selects exist
                    {
                        foreach($folder3 in $order_folders)
                        {
                            if($folder3.fullname.contains("Edits"))
                            {
                                $edits = Get-ChildItem $folder3.FullName
                                if($edits.Length > 20)
                                {
                                    echo $($folder.fullname + "," + $selects.Length + "," + $edits.Length);
                                }
                            }
                        }
                    }
                    else
                    {
                        foreach($folder3 in $order_folders)
                        {
                            if($folder3.fullname.contains("Edits"))
                            {
                                $edits = Get-ChildItem $folder3.FullName
                                if($edits.Length > 20)
                                {
                                    echo $($folder.fullname + "," + $selects.Length + "," + $edits.Length);
                                }
                            }
                        
                    }
                }
            }
           #echo $order_folders
        }
   } }

}