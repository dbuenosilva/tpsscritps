Set-ExecutionPolicy remotesigned



$lookup_folder = 'H:\Melbourne\'

$list = Get-ChildItem $lookup_folder

 for($i=0;$i -lt $list.length -1;$i++)
 {
   
  $list[$i]=$list[$i].name
  #echo $list[$i]
 }
echo $list.length

$guess = Get-ChildItem $($lookup_folder + $list[2]+'\'+'*RETOUCH*\'+'*Done*\')
get-childitem $($guess.FullName + '\hi*\')
