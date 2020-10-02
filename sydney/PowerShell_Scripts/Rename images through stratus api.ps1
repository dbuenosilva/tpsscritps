Function Get-RootFolder()
{
    [System.reflection.assembly]::LoadWithPartialName("System.windows.forms")|Out-null
    $SelectFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $SelectFolderDialog.Description = "Select the Root folder with all the image folders"
    
    $folderselected = $false
    while(!($folderselected))
    {
        if($SelectFolderDialog.ShowDialog() -eq "OK")
        {
            $folderselected = $true;
        }
    }
    $SelectFolderDialog.SelectedPath
    $SelectFolderDialog.Dispose()
}

Function Get-FileExtension($filename)
{
    $extension = $filename.substring($filename.lastindexof("."))
}

Function Parse-CSNumber($filename2)
{
    <#
    Parse the client/session number from the image name.
    Assumptions:
        1.Image numbers contain client or session number at the beginning. (as per the standard image naming protocol)
        2.Some images have "1_" or "1-" at the beginning of their names.
        3.All standard naming protocols were followed properly during the image upload by the studio.
    #>

    # parse the client / session number from the filename
    $fcs_number = ""
    if($filename2.Substring(0,1) -eq "1")
    {
        $fcs_number = $filename2.Substring(2,$filename2.LastIndexOf("_")-2);
    }
    else
    {
        $fcs_number = $filename2.Substring(0,$filename2.LastIndexOf("_"))
    }

    if($fcs_number.Contains("_"))
    {
        $fcs_number = $fcs_number.Substring(0,$fcs_number.LastIndexOf("_"))
    }
    return $fcs_number
}


$rootDirectory = Get-RootFolder

$subdirs = Get-ChildItem $rootDirectory -Directory -Recurse


#Prepping stratus connector...
$session_url = "https://api.thephotostudio.com.au/sp/session?action=Sessionnumber&value="
$client_url = "https://api.thephotostudio.com.au/sp/client?action=number&value="
$Headers = @{
            "x-api-key"="2Dwgd1IsyYaNbCzaNT8mLIbtJrw3VZ45Kw53QU3d"
            }


#initialize key-value variable
$cs_number_names = New-Object System.Collections.Hashtable

for($i=0;$i -lt $subdirs.Length;$i++)
{
   Write-Host "working on directory: " $subdirs[$i].Name
   $images = Get-ChildItem $subdirs[$i].FullName

   #loop through each subfolder.
   for($j=0;$j -lt $images.Length;$j++)
   {
    
    $cs_number = Parse-CSNumber $images[$j].Name
    write-host "Checking number " $cs_number

    #apply the secret sauce.
    $new_name = ""
    if($cs_number_names.ContainsKey($cs_number)) #$cs_number_names.ContainsKey($cs_number)
    {
        if($cs_number_names.Item($cs_number) -eq "-1")
        {
            Write-Host "Following not found: "
        }
        else
        {
            $new_name = $($images[$j].name.Replace($cs_number,$($cs_number_names.item($cs_number) + " " + $subdirs[$i].Name)))
            Rename-Item -Path $images[$j].FullName -NewName $new_name
            #Write-Host "Renamed: " + $cs_number + " --> " + $cs_number_names.Item($cs_number)
        }
    }
    #if not already in the key-value store. make an API call.
    else
    {
        $client_full_name = ""
        try
        {
            $client_data = Invoke-RestMethod -uri $($client_url + $cs_number) -Headers $Headers
            $client_full_name = $($client_data.firstname + " " + $client_data.LastName)
            if(!$client_full_name -eq "")
            {
                try
                {
                    $cs_number_names.Add($cs_number,$client_full_name)
                }
                catch
                {
                }
            }
        }
        catch
        {
            $client_data = Invoke-RestMethod -uri $($session_url + $cs_number) -Headers $Headers
            $client_data = Invoke-RestMethod -uri $($client_url + $client_data.clientNumber) -Headers $Headers
            $client_full_name = $($client_data.firstname + " " + $client_data.LastName)
            if(!$client_full_name -eq "")
            {
                try
                {
                    $cs_number_names.Add($cs_number,$client_full_name)
                }
                catch
                {
                }
            }
        }
        Clear-Variable client_data
        $cs_number_names.Add($cs_number,$cs_number_names)
        $new_name = $($images[$j].Name.Replace($cs_number,$($cs_number_names.item($cs_number) + " " + $subdirs[$i].Name)))
        Rename-Item -Path $images[$j].FullName -NewName $new_name
        #Write-Host "Renamed: " + $cs_number + " --> " + $cs_number_names.Item($cs_number)
    }

        
   }
}

Clear-Variable rootDirectory, subdirs, Headers,images, session_url, client_url,cs_number
