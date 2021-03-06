
$TimeStart = Get-Date
$TimeEnd = "23:52:00"


function LogCleanUp{
$RemoveLogAfterDays = "7"
$Extension = "*.csv"
$LastWrite = $TimeStart.AddDays(-$RemoveLogAfterDays)
$LogFileFolder = "C:\Temp\Pinglog" 
$Files = Get-Childitem $LogFileFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($File in $Files) 
    {
    if ($File -ne $NULL)
        {
        write-host "Deleting File $File" 
        Remove-Item $File.FullName | out-null
        }
    else
        {
        Write-Host "No more files to delete!"
        }
    }
}

workflow PingTest { 
    $TargetComputers = @("hv-hp","hv-dell")
    
    Foreach ($Computer in $TargetComputers){
        $SourceComputer = "MININT-474A75O"    
        $Time = Get-Date
        $TestResult = Test-Connection -ComputerName $Computer -Count 1 -ErrorAction SilentlyContinue
        inlinescript{
            if ($using:TestResult.ResponseTime -eq $null){
                $ResponseTime = -1
            } else {
                $ResponseTime = $using:TestResult.ResponseTime
            }
            $ResultObject = New-Object PSObject -Property @{Time = $using:Time; Source = $using:SourceComputer ;Target = $using:Computer; ResponseTime = $ResponseTime}
            $TimeStartSortable = Get-Date -format "yyyyMMdd" 
            $Logfile = "C:\Temp\Pinglog\PingLog_$($TimeStartSortable)_$($using:SourceComputer)_$($using:Computer).csv" 
            Export-Csv -InputObject $ResultObject $Logfile -Append
        }
    }
}

Clear-Host
Write-Host "Start Time: $Logfile"
Write-Host "Start Time: $TimeStart"
write-host "End Time:   $TimeEnd"

LogCleanUp

Do { 
 $TimeNow = Get-Date
 if ($TimeNow -ge $TimeEnd) {
  Write-host "All done for the Day!"
 } else {
  Write-Host "Not done yet, it's only $TimeNow"
  Write-Host $TimeNow "Testing..." 
  PingTest
  Write-Host "Sleeping..."
  Start-Sleep -Seconds 30
 }
}
Until ($TimeNow -ge $TimeEnd)