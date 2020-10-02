$SMD = Get-ChildItem "\\galaxy\imagedata\0_CLIENT FOLDER\*_??\*_Productions\*_RETOUCH\*_Done*\Screen Res\*.jpg" -File;
$DESTINATION = 
$start = Get-Date;
for($i = 0;$i -lt $SMD.Length;$i++)
{
    #$files = Get-ChildItem $dir[$i] -File;
    #for($j = 0;$j -lt $files.Length;$j++)
    #{
        echo "Created:" $SMD[$i].name ": " ($SMD[$i].CreationTime.dayofyear -gt 182);
        #echo $files[$j].CreationTime.dayofyear.compareto(182);
    #}
}
$end = Get-Date
$ts = New-TimeSpan -Start $start -End $end
$ts.Milliseconds
