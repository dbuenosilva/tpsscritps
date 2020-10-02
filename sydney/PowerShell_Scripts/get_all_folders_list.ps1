$folders = Get-ChildItem "\\andromeda\Imagedata\01_Client_Folder\" -Directory

for($i=0;$i -lt $folders.Length;$i++)
{
$index_of_ = $folders[$i].Name.IndexOf("_")
 if($index_of_ -ne '-1')
 {
    if($folders[$i].Name.StartsWith("300"))
    {
        $folders[$i] = $folders[$i].Name.Substring(0,$index_of_)
        echo $folders[$i]
    }
 }
}
#echo $folders.Name