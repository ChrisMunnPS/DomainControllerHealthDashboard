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
.\ADHealthDashboard.ps1
```


Requirements
- PowerShell 5.1 or later
- RSAT: Active Directory module installed
- Administrative privileges to query domain controllers and read event logs
- Network access to all DCs in scope

Screenshot
Preview of the HTML dashboard (dark theme with color-coded health indicators):

![AD Health Dashboard Screenshot](https://github.com/ChrisMunnPS/DomainControllerHealthDashboard/blob/main/ADHealthDashboard.png)



Preview of the markdown file
[View AD Health Dashboard Report (Markdown)](https://github.com/ChrisMunnPS/DomainControllerHealthDashboard/blob/main/ADHealthDashboard_20250921_163946.md)


## 👤 Author

**Chris Munn**  
🛠️ *Mid-to-Senior Windows Systems Administrator*  
🎯 *Specializing in automation, infrastructure health, and secure reporting*  
📜 *Microsoft Certified*:  
- Azure Administrator Associate (AZ-104)  
- MS-900, SC-900, AZ-900  
- Active Directory Domain Services Applied Skills  

💡 *Core Skills*:  
- PowerShell scripting & modular function design  
- Advanced AD diagnostics & FSMO role analysis  
- Markdown/HTML reporting for technical transparency  
- Docker Compose & container security  
- Hardware troubleshooting & workspace customization  

🐾 *Creative Companion*:  
Esme — a quiet, orange British short-haired cat who supervises every script in payment of treats, specifically dreamies.


📫 *Connect*:  
Feel free to reach out via [LinkedIn](https://www.linkedin.com/in/chrismunnps) or explore more projects on [GitHub](https://github.com/ChrisMunnPS).
License
MIT License — feel free to use, modify, and share with attribution.

