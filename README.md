### PowerShell Domain Controller Health Check Script

This PowerShell script provides a comprehensive health check for all Domain Controllers (DCs) in your environment. Designed for system administrators and IT professionals, it automates the process of validating critical services and replication status, providing a clear and easy-to-read report.

**Key Features:**

* **Connectivity Check**: Verifies that each DC is reachable on the network using `Test-Connection`.
* **Active Directory Replication**: Uses `Get-ADReplicationPartnerMetadata` to check for any replication failures between DCs.
* **Time Synchronization**: Confirms that the **Windows Time service (W32Time)** is running on each DC, which is vital for proper authentication.
* **DNS Health**: Executes `DCDIAG /test:dns` to perform a thorough check of each DC's DNS functionality and SRV record registration.
* **Dual Reporting**: Generates both a professional, color-coded **HTML dashboard** and a simple **Markdown report** for easy sharing and documentation.
* **Automated Actions**: The script automatically opens the HTML report in the default browser upon completion. It also includes commented-out code for optional email or Microsoft Teams notifications to enable proactive alerting.
* **Customizable**: The script can be easily configured to add or modify checks, and the output reports are saved to the user's desktop for quick access.
