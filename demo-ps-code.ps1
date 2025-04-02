##SQL Server Health Check Report Using PowerShell##

###### version 1 - basic query
Invoke-Sqlcmd -ServerInstance localhost -Query "select name, state_desc from sys.databases"

###### version 2 - basic layout
$DB = Invoke-Sqlcmd -ServerInstance localhost -Query "select name, state_desc from sys.databases"
#$DB | Get-Member
##Covert the result of $DB to a html report
$DB | ConvertTo-Html -As Table -Property name, state_desc | Out-File -FilePath C:\Temp\sqlserver-report.html
Invoke-Item C:\Temp\sqlserver-report.html

###### version 4 - adding css style
$CSS = @"
<style>
    body { font-family: Arial, sans-serif; margin: 20px; padding: 10px; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color:rgb(29, 32, 156); color: white; }
</style>
"@
$DB=Invoke-Sqlcmd -ServerInstance localhost -Query "select name, state_desc from sys.databases" 
$DB | ConvertTo-Html -As Table -Property name,state_desc -PreContent "<h1>DB Status Report</h1>" -Title "Health Check Report" -Head $css| Out-File "C:\temp\SQLDatabases-1.html"
Invoke-Item "C:\temp\SQLDatabases-1.html"

###### version 5 - adding css style + additional query + extra powershell cmdlet output
$CSS = @"
<style>
    body { font-family: Arial, sans-serif; margin: 20px; padding: 10px; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: rgb(86, 184, 89); color: white; }
    tr:nth-child(even) { background-color: #f2f2f2; }
</style>
"@
$DB_V1 = Invoke-Sqlcmd -ServerInstance localhost -Query "select name, state_desc from sys.databases"
$DBhtml = $DB_V1 | ConvertTo-Html -As Table -Property name, state_desc -Title "DB Status Report" -PreContent "<h1>DB Status</h1>" | Out-String

$job_v1= Invoke-Sqlcmd -ServerInstance localhost -Query "select name, enabled from msdb..sysjobs"
$jobhtml = $job_v1 | ConvertTo-Html -As Table -Property name, enabled -Title "SQL Jobs" -PreContent "<h1>SQL Jobs</h1>" | Out-String

$servicestatus = Get-Service *SQL* | Select-Object Name, Status
$servicestatushtml = $servicestatus | ConvertTo-Html -As Table -Property Name, Status -PreContent "<h1>SQL Services Status</h1>" | Out-String

$finaloutput = "$CSS  $DBhtml $jobhtml $servicestatushtml"

$path = "C:\Temp\SQLServerHealthCheckReport.html"
$finaloutput | Out-File -FilePath $path 
Invoke-Item $path
