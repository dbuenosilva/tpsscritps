$dir = get-childitem "\\andromeda\imagedata\2018 Uploads\01_ARCHIVE PENDING\" -Directory

for($i=0;$i -lt $dir.Length;$i++)
{ 
$subdirs =  Get-ChildItem $dir[$i].fullname;
if($subdirs.length -lt 2)
{
echo $subdirs.fullname
}
#if($dir[$i].Name.Contains("Upload"))
#{
 #   echo $dir[$i].FullName
#}
}