$comps = Get-ADcomputer -Filter * -SearchBase 'OU=Producers Workstations,OU=Melbourne,OU=Devices,DC=THEPHOTOSTUDIO,DC=local' | % {$_.name}
foreach($comp in $comps) 
{ 
if (test-connection -quiet -count 1 -computername $comp) 
{
Get-WmiObject -ComputerName $comp -Class Win32_NetworkAdapter | Where-Object { $_.Speed -ne $null -and $_.MACAddress -ne $null } | Format-Table -Property SystemName,Name,NetConnectionID,@{Label='Speed(GB)'; Expression = {$_.Speed/1024.0} 
} 
}
}