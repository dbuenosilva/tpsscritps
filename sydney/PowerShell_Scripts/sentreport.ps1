$uploads_location = "D:\Dropbox\0_RETOUCHING\NEW WORK\12 OCT\";
$uploads = Get-ChildItem  $uploads_location;
$sent_record =@();


for($i=0;$i -lt $uploads.Length;$i++)
{
    $child_files = Get-ChildItem -Exclude *pdf,*odt $($uploads_location + "\" + $uploads[$i]);
    $sent_record += $($uploads[$i].Name + " (" + $child_files.Count + ")" );
    

}
echo $sent_record;