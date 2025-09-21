# Active Directory Health Report

Generated on 21 September 2025 16:39

## DC Health Scores

- **DC1.Homelan.lab**: 100%
- **DC2.Homelan.lab**: 95%

## Health Overview

| Test | DC1.Homelan.lab | DC2.Homelan.lab |
|------|------|------|
| Advertising | ✅ | ✅ |
| CheckSDRefDom | ✅ | ✅ |
| Connectivity | ✅ | ✅ |
| CrossRefValidation | ✅ | ✅ |
| DFSREvent | ✅ | ✅ |
| FrsEvent | ✅ | ✅ |
| Intersite | ✅ | ✅ |
| KccEvent | ✅ | ✅ |
| KnowsOfRoleHolders | ✅ | ✅ |
| LocatorCheck | ✅ | ✅ |
| MachineAccount | ✅ | ✅ |
| NCSecDesc | ✅ | ✅ |
| NetLogons | ✅ | ✅ |
| ObjectsReplicated | ✅ | ✅ |
| Ping | ✅ | ✅ |
| Replications | ✅ | ✅ |
| RidManager | ✅ | ✅ |
| Services | ✅ | ✅ |
| SystemErrors24h | N/A | ❌ (5) |
| SystemLog | ✅ | ✅ |
| SysVolCheck | ✅ | ✅ |
| VerifyReferences | ✅ | ✅ |

## Failure Details

### DC2.Homelan.lab (1 issues)

#### SystemErrors24h

09/21/2025 11:52:02 - EventID: 1796 - Source: Microsoft-Windows-TPM-WMI
The Secure Boot update failed to update a Secure Boot variable with error -2147020471. For more information, please see https://go.microsoft.com/fwlink/?linkid=2169931

09/21/2025 11:52:02 - EventID: 1796 - Source: Microsoft-Windows-TPM-WMI
The Secure Boot update failed to update a Secure Boot variable with error -2147020471. For more information, please see https://go.microsoft.com/fwlink/?linkid=2169931

09/21/2025 06:33:47 - EventID: 7 - Source: KDC
The Security Account Manager failed a KDC request in an unexpected way. The error is in the data field. The account name was  and lookup type 0x108.

09/20/2025 23:52:02 - EventID: 1796 - Source: Microsoft-Windows-TPM-WMI
The Secure Boot update failed to update a Secure Boot variable with error -2147020471. For more information, please see https://go.microsoft.com/fwlink/?linkid=2169931

09/20/2025 23:52:02 - EventID: 1796 - Source: Microsoft-Windows-TPM-WMI
The Secure Boot update failed to update a Secure Boot variable with error -2147020471. For more information, please see https://go.microsoft.com/fwlink/?linkid=2169931




