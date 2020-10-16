$file_name=Read-Host "Enter the File Name"
$source_File=Get-ChildItem -Path "\\192.168.33.46\imagedata\01_CLIENT_FOLDER\" -Name
$destination_File1=Get-ChildItem -Path "D:\Archives" -Name
$destination_File2=Get-ChildItem -Path "F:\Archives" -Name
$destination_File3=Get-ChildItem -Path "G:\" -Name
$session_list=Compare-Object -ReferenceObject $source_File -DifferenceObject ($destination_File1+$destination_File2+$destination_File3)  |  Where-Object {$_.sideIndicator -eq "<=" -and $_.inputObject -match "400"} | Format-Table -Property InputObject
$session_list | Out-File -FilePath C:\archiveworks\$file_name.txt