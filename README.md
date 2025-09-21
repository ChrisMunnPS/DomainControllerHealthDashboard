# Active Directory Health Dashboard

## Executive Summary

This PowerShell-based dashboard provides a clear, visual overview of Active Directory domain controller health across an enterprise environment. Designed for infrastructure transparency, it generates both HTML and Markdown reports that highlight system status, error trends, and diagnostic results in a format suitable for technical review or executive presentation.

The script reflects a commitment to automation, maintainability, and secure reporting — ideal for organizations prioritizing operational resilience and proactive infrastructure monitoring.

---

## Technical Overview

This script performs a comprehensive health check across all domain controllers in an Active Directory forest. It includes:

- **Ping validation** to confirm DC availability  
- **DCDiag parsing** to extract test results and failure details  
- **System error log analysis** from the past 24 hours  
- **Health scoring** per DC based on pass/fail ratios  
- **Failure summaries** with detailed diagnostics  

### Output

- **HTML Report**: Dark-themed, tech-styled dashboard with color-coded results  
- **Markdown Report**: Lightweight, portable summary for documentation or GitHub display  
- Both reports are saved to the same directory where the script is executed, timestamped for audit clarity.

### Usage

```powershell
# Run the script with admin privileges
.\Invoke-ADHealthCheck.ps1
