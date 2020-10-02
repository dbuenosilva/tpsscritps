#$Full_User_Path=whoami
#$user=$Full_User_Path.Substring($Full_User_Path.LastIndexOf('\')+1)
$env:Path = $env:Path + ";C:\PSConsole"
$Client_File_Path=Read-Host "Please Enter the Clinet Folder Path"
$Client_ID=$Client_File_Path.Substring($Client_File_Path.LastIndexOf('\')+1)
cd C:\PSConsole\
& ./PSConsole newAlbum saveChanges='false'
& ./PSConsole  addImageFolder $Client_File_Path
& ./PSConsole saveAlbumAs $Client_File_Path\$Client_ID' Album.psa'
