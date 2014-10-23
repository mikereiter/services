<#
.SYNOPSIS
    Find Services
.DESCRIPTION
    Small PS script to find bad Services on remote systems
.EXAMPLE
    .\services.ps1
    Make sure a hosts.txt exists in same directory
.NOTES
    Author: Mike Reiter CBTS ACS
    Date:  October 2014   
#>
$hostfile="hosts.txt"
if (Test-Path $hostfile)
{
}
else
{
  Write-Host "[!] No hosts.txt found."
  Exit
}
Write-Host
$UserName = Read-Host "Domain\Username" 
$Password = Read-Host -AsSecureString "Password" 
$Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username, $Password
$ErrorActionPreference = "Stop"
Write-Host
ForEach ($system in Get-Content "hosts.txt")
{
    Write-Host -NoNewline "[*] Getting Service list for $system..."
    Try
    {
        gwmi win32_service -ComputerName $system -Credential $credential | select SystemName,Name,DisplayName,StartMode,State,PathName | export-csv -append -path output.csv -NoType
        Write-Host  " Done."
    }
    Catch
    {
        Write-Host " Unavailable."
    }
}
$Result = test-path "output.csv"
if ($Result)
{
    Write-Host "[!] Results written to output.csv."
    Write-Host
    Write-Host "[*] Sorting results..."
    $data= @()
    ForEach ($line in Get-Content "output.csv")
    {
        $name = $line.Split(",")[1]
        $path = $line.Split(",")[5]
        $data += "$name,$path"
    }
    $data = $data[1..$($data.Length)]
    $data | Group-Object -NoElement | Sort-Object count | format-table -auto | Out-File "sorted.txt"
    Write-Host "[!] Results written to sorted.txt."
    Write-Host
}
else
{
    Write-Host
    Write-Host "[!] All systems offline/unavailable."
}