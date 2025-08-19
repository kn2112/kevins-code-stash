<# 
   Powershell script to get names of AD computers
   which have not logged in for at least 60 days
#>

$DaysInactive = 60
$time = (Get-Date).Adddays(-($DaysInactive))
Get-ADComputer -Filter {LastLogonDate -lt $time} -Properties Name, LastLogonDate | select name, LastLogonDate
