snippingtool /clip
$p = Get-Process snippingtool
Wait-Process -Id $p.Id;
$s = Get-Clipboard -Format Image;
$f = $("C:\ScreenClips\Screen-Clip " + $(Get-Date -Format %d-%M-%y-%h-%m-%s) + ".png");
$s.save($f);