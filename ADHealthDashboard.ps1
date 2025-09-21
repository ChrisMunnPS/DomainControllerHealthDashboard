# Requires RSAT tools and admin privileges
Import-Module ActiveDirectory

$dcs = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName
$results = @{}
$failureDetails = @{}
$allTests = New-Object System.Collections.Generic.HashSet[string]

foreach ($dc in $dcs) {
    $results[$dc] = @{}
    $failureDetails[$dc] = @{}

    $ping = Test-Connection -ComputerName $dc -Count 1 -Quiet
    $pingStatus = if ($ping) { "PASS" } else { "FAIL" }
    $results[$dc]["Ping"] = $pingStatus
    $allTests.Add("Ping") | Out-Null
    if ($pingStatus -eq "FAIL") {
        $failureDetails[$dc]["Ping"] = "Failed to ping the domain controller. It may be offline or unreachable due to network issues."
    }

    $dcdiagOutput = Invoke-Command -ComputerName $dc -ScriptBlock { dcdiag }
    $currentTest = ""
    $testBuffer = @()

    foreach ($line in $dcdiagOutput) {
        if ($line -match "Starting test: (\w+)") {
            $currentTest = $matches[1]
            $testBuffer = @()
            continue
        }

        if ($currentTest -ne "") {
            $testBuffer += $line.Trim()
        }

        if ($line -match "\.*\s+(passed|failed) test (\w+)") {
            $status = if ($matches[1] -eq "passed") { "PASS" } else { "FAIL" }
            $test = $matches[2]
            if ($test -eq $currentTest) {
                $results[$dc][$test] = $status
                $allTests.Add($test) | Out-Null
                if ($status -eq "FAIL") {
                    $details = ($testBuffer | Where-Object { $_ -notmatch "\.*\s+(passed|failed) test" -and $_ -ne "" }) -join "`n"
                    $failureDetails[$dc][$test] = $details
                }
                $currentTest = ""
                $testBuffer = @()
            }
        }
    }

    $errors = Invoke-Command -ComputerName $dc -ScriptBlock {
        Get-EventLog -LogName System -After (Get-Date).AddHours(-24) -EntryType Error |
        Select-Object TimeGenerated, EventID, Source, Message
    }
    $errorCount = $errors.Count
    $results[$dc]["SystemErrors24h"] = $errorCount
    $allTests.Add("SystemErrors24h") | Out-Null
    if ($errorCount -gt 0) {
        $eventDetails = ($errors | ForEach-Object {
            "$($_.TimeGenerated) - EventID: $($_.EventID) - Source: $($_.Source)`n$($_.Message -replace "`n", "`n")`n`n"
        }) -join ""
        $failureDetails[$dc]["SystemErrors24h"] = $eventDetails
    }
}

$sortedTests = $allTests | Sort-Object
$health = @{}
foreach ($dc in $dcs) {
    $success = 0; $total = 0
    foreach ($test in $sortedTests) {
        $status = $results[$dc][$test]
        if ($null -ne $status) {
            $total++
            $isGood = if ($test -eq "SystemErrors24h") { $status -eq 0 } else { $status -eq "PASS" }
            if ($isGood) { $success++ }
        }
    }
    $health[$dc] = if ($total -gt 0) { [math]::Round(($success / $total) * 100) } else { 0 }
}

$reportDate = Get-Date -Format "dd MMMM yyyy HH:mm"

# Markdown report
$md = "# Active Directory Health Report`n`n"
$md += "Generated on $reportDate`n`n"
$md += "## DC Health Scores`n`n"
foreach ($dc in $dcs) {
    $score = $health[$dc]
    $md += "- **$dc**: $score%`n"
}
$md += "`n## Health Overview`n`n| Test |"
foreach ($dc in $dcs) { $md += " $dc |" }
$md += "`n|------|" + ("------|" * $dcs.Count) + "`n"
foreach ($test in $sortedTests) {
    $md += "| $test |"
    foreach ($dc in $dcs) {
        $status = $results[$dc][$test]
        if ($null -eq $status) {
            $md += " N/A |"
        } elseif ($test -eq "SystemErrors24h") {
            $md += if ($status -eq 0) { " ✅ (0) |" } else { " ❌ ($status) |" }
        } else {
            $md += if ($status -eq "PASS") { " ✅ |" } else { " ❌ |" }
        }
    }
    $md += "`n"
}
$md += "`n## Failure Details`n`n"
foreach ($dc in $dcs) {
    if ($failureDetails[$dc].Count -gt 0) {
        $md += "### $dc ($($failureDetails[$dc].Count) issues)`n`n"
        foreach ($test in ($failureDetails[$dc].Keys | Sort-Object)) {
            $details = $failureDetails[$dc][$test]
            $md += "#### $test`n`n$details`n`n"
        }
    }
}

# HTML report
$html = @"
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <title>Active Directory Health Dashboard</title>
  <style>
    body { background-color: #1e1e2f; color: #e0e0e0; font-family: 'Segoe UI', Tahoma, sans-serif; padding: 20px; }
    header { text-align: center; padding-bottom: 20px; border-bottom: 2px solid #444; }
    h1 { color: #00ffff; font-size: 2em; margin-bottom: 5px; }
    h2 { color: #00ff99; margin-top: 30px; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #555; padding: 8px; text-align: center; }
    th { background-color: #2a2a3d; color: #00ffff; }
    tr:nth-child(even) { background-color: #2e2e40; }
    .pass { color: #00ff00; font-weight: bold; }
    .fail { color: #ff4444; font-weight: bold; }
    .na { color: #999; }
    footer { text-align: center; margin-top: 40px; font-size: 0.9em; color: #888; }
  </style>
</head>
<body>
  <header>
    <h1>Active Directory Health Dashboard</h1>
    <p>Generated on <strong>$reportDate</strong></p>
  </header>
"@
$html += "<h2>DC Health Scores</h2><ul>"
foreach ($dc in $dcs) {
    $score = $health[$dc]
    $html += "<li><strong>$dc</strong>: $score%</li>"
}
$html += "</ul><h2>Health Overview</h2><table><tr><th>Test</th>"
foreach ($dc in $dcs) { $html += "<th>$dc</th>" }
$html += "</tr>"
foreach ($test in $sortedTests) {
    $html += "<tr><td>$test</td>"
    foreach ($dc in $dcs) {
        $status = $results[$dc][$test]
        if ($null -eq $status) {
            $html += "<td class='na'>N/A</td>"
        } elseif ($test -eq "SystemErrors24h") {
            $html += if ($status -eq 0) { "<td class='pass'>0</td>" } else { "<td class='fail'>$status</td>" }
        } else {
            $html += if ($status -eq "PASS") { "<td class='pass'>PASS</td>" } else { "<td class='fail'>FAIL</td>" }
        }
    }
    $html += "</tr>"
}
$html += "</table><h2>Failure Details</h2>"
foreach ($dc in $dcs) {
    if ($failureDetails[$dc].Count -gt 0) {
        $html += "<h3>$dc ($($failureDetails[$dc].Count) issues)</h3>"
        foreach ($test in ($failureDetails[$dc].Keys | Sort-Object)) {
                        $details = $failureDetails[$dc][$test] -replace "<", "&lt;" -replace ">", "&gt;"
            $html += "<h4>$test</h4><pre>$details</pre>"
        }
    }
}

$html += "<footer>&copy; 2025 Infrastructure Insights | Powered by PowerShell and HTML</footer></body></html>"

# Save both reports to the same directory
$scriptDir = if ($MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    Get-Location
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$htmlFile = Join-Path $scriptDir "ADHealthDashboard_$timestamp.html"
$mdFile = Join-Path $scriptDir "ADHealthDashboard_$timestamp.md"

$html | Out-File -FilePath $htmlFile -Encoding utf8
$md | Out-File -FilePath $mdFile -Encoding utf8

Write-Output "HTML report saved to: $htmlFile"
Write-Output "Markdown report saved to: $mdFile"

Invoke-Item $htmlFile
