# Load required module
Import-Module ActiveDirectory

# Create timestamp for output
$ReportDate = Get-Date -Format "yyyyddMM"
$HTMLPath = "$env:USERPROFILE\Desktop\DomainControllerHealthReport_$ReportDate.html"
$MarkdownPath = "$env:USERPROFILE\Desktop\DomainControllerHealthReport_$ReportDate.md"
$CriticalIssues = @()

# Discover domain controllers
$DomainControllers = Get-ADDomainController -Filter *
$Results = @()

foreach ($DC in $DomainControllers) {
    $DCName = $DC.HostName
    $Status = [PSCustomObject]@{
        'DC Name' = $DCName
        'Reachable' = $false
        'Replication OK' = $false
        'Time Sync OK' = $false
        'DNS Healthy' = $false
    }

    # Check basic connectivity
    if (Test-Connection -ComputerName $DCName -Count 2 -Quiet) {
        $Status.Reachable = $true

        # --- Enhanced Replication Check ---
        $ReplFailures = Get-ADReplicationPartnerMetadata -Target $DCName -ErrorAction SilentlyContinue |
            Where-Object { $_.LastReplicationResult -ne 0 }

        if ($null -eq $ReplFailures) {
            $Status.'Replication OK' = $true
        } else {
            $CriticalIssues += "Replication failures found on $DCName. Check partners: $($ReplFailures.Partner)"
        }

        # Time sync
        $W32Time = Get-Service -ComputerName $DCName -Name "W32Time" -ErrorAction SilentlyContinue
        if ($W32Time.Status -eq 'Running') {
            $Status.'Time Sync OK' = $true
        } else {
            $CriticalIssues += "Time service not running on $DCName"
        }

        # --- Enhanced DNS Check ---
        $DCDiagResult = dcdiag /test:dns /s:$DCName /q
        if ($DCDiagResult -notmatch "failed|warning") {
            $Status.'DNS Healthy' = $true
        } else {
            $CriticalIssues += "DCDIAG found DNS issues on $DCName"
        }

    } else {
        $CriticalIssues += "$DCName is unreachable"
    }

    $Results += $Status
}

# 🌈 Display dashboard with per-value coloring
Write-Host "`n===================================" -ForegroundColor Cyan
Write-Host "🖥 DOMAIN CONTROLLER HEALTH DASHBOARD" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

foreach ($entry in $Results) {
    Write-Host "`n$($entry.'DC Name') Health Check" -ForegroundColor Yellow

    foreach ($key in @('Reachable', 'Replication OK', 'Time Sync OK', 'DNS Healthy')) {
        $value = $entry | Select-Object -ExpandProperty $key
        if ($value) {
            Write-Host "$($key): $($value)" -ForegroundColor Green
        } else {
            Write-Host "$($key): $($value)" -ForegroundColor Red
        }
    }
}


# 📝 Build Markdown report
$Markdown = @"
# Domain Controller Health Report
**Report Date**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

| DC Name | Reachable | Replication OK | Time Sync OK | DNS Healthy |
|---|---|---|---|---|
"@

foreach ($entry in $Results) {
    $Markdown += "| $($entry.'DC Name') | $($entry.Reachable) | $($entry.'Replication OK') | $($entry.'Time Sync OK') | $($entry.'DNS Healthy') |`n"
}

$Markdown += "`n## Alerts and Issues Found`n"
if ($CriticalIssues.Count -gt 0) {
    foreach ($issue in $CriticalIssues) {
        $Markdown += "- $issue`n"
    }
} else {
    $Markdown += "- No critical issues found. All systems go!`n"
}

$Markdown | Out-File -Encoding UTF8 -FilePath $MarkdownPath


# 🖥 Build HTML report (Corrected to avoid parsing errors)
$Style = @"
<style>
body { font-family: Arial, sans-serif; }
h1 { color: #333; }
table { border-collapse: collapse; width: 100%; margin-top: 20px; }
th, td { text-align: left; padding: 8px; border: 1px solid #ddd; }
th { background-color: #f2f2f2; }
.true { background-color: #d4edda; color: #155724; }
.false { background-color: #f8d7da; color: #721c24; }
.issues-container { margin-top: 40px; padding: 20px; border: 1px solid #f5c6cb; background-color: #fff3f4; border-radius: 5px; }
.issues-title { color: #721c24; }
</style>
"@

$Header = @"
<h1>Domain Controller Health Report</h1>
<p><b>Report Date:</b> $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
"@

# Create a new, temporary object with sanitized property names to avoid parsing issues
$SanitizedResults = @()
foreach ($item in $Results) {
    $SanitizedResults += [PSCustomObject]@{
        'DC Name' = $item.'DC Name'
        'Reachable' = $item.Reachable
        'Replication OK' = $item.'Replication OK'
        'Time Sync OK' = $item.'Time Sync OK'
        'DNS Healthy' = $item.'DNS Healthy'
    }
}

$HTMLTable = $SanitizedResults | ConvertTo-Html -Fragment | Out-String
$HTMLTable = $HTMLTable -replace '<td>True</td>', '<td class="true">True</td>'
$HTMLTable = $HTMLTable -replace '<td>False</td>', '<td class="false">False</td>'

$IssuesSection = ""
if ($CriticalIssues.Count -gt 0) {
    $IssuesList = $CriticalIssues | ForEach-Object { "<li>$_</li>" }
    $IssuesSection = @"
<div class="issues-container">
    <h2 class="issues-title">Alerts and Issues Found</h2>
    <ul>
        $($IssuesList -join "`n")
    </ul>
</div>
"@
} else {
    $IssuesSection = @"
<div class="issues-container" style="border-color: #c3e6cb; background-color: #d4edda;">
    <h2 style="color: #155724;">All Systems Go!</h2>
    <p>No critical issues were found during the health check.</p>
</div>
"@
}

$HTMLContent = "$Header$HTMLTable$IssuesSection"

ConvertTo-Html -Head $Style -Body $HTMLContent | Out-File -Encoding UTF8 -FilePath $HTMLPath


# Final output and actions
Write-Host "`n✅ Markdown report saved to: $MarkdownPath"
Write-Host "`n✅ HTML report saved to: $HTMLPath"

# Opens the HTML report in the default web browser
Start-Process $HTMLPath

# ✉️ Optional email alert (uncomment and configure if needed)
<#
Send-MailMessage -To 'admin@example.com' -From 'dc-monitor@example.com' `
    -Subject "Domain Controller Health Alert - $ReportDate" `
    -Body ($CriticalIssues -join "`n") `
    -SmtpServer 'smtp.example.com'
#>

# 📣 Optional Microsoft Teams notification via webhook
<#
$TeamsPayload = @{
    title = "Domain Controller Health Check"
    text = "Issues detected:`n" + ($CriticalIssues -join "`n")
}
Invoke-RestMethod -Uri 'https://your-teams-webhook-url' -Method POST -Body ($TeamsPayload | ConvertTo-Json -Depth 2) -ContentType 'application/json'
#>
