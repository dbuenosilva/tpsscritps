Set-ExecutionPolicy remotesigned
#$list = Read-Host 'Enter the file containing the list'


#if(Test-Path $list) tests for file existance

$lookup_folder = '\\GALAXY\imagedata\0_CLIENT FOLDER\01_ARCHIVE PENDING\New folder\'

$list = Get-ChildItem $lookup_folder

 for($i=0;$i -lt $list.length;$i++)
 {
   
  $list[$i].name;
  
 }
echo $list.length
echo 'done processing'