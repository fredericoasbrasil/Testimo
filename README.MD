﻿<p align="center">
  <a href="https://www.powershellgallery.com/packages/Testimo"><img src="https://img.shields.io/powershellgallery/v/Testimo.svg"></a>
  <a href="https://www.powershellgallery.com/packages/Testimo"><img src="https://img.shields.io/powershellgallery/vpre/Testimo.svg?label=powershell%20gallery%20preview&colorB=yellow"></a>
  <a href="https://github.com/EvotecIT/Testimo"><img src="https://img.shields.io/github/license/EvotecIT/Testimo.svg"></a>
</p>

<p align="center">
  <a href="https://www.powershellgallery.com/packages/Testimo"><img src="https://img.shields.io/powershellgallery/p/Testimo.svg"></a>
  <a href="https://github.com/EvotecIT/Testimo"><img src="https://img.shields.io/github/languages/top/evotecit/Testimo.svg"></a>
  <a href="https://github.com/EvotecIT/Testimo"><img src="https://img.shields.io/github/languages/code-size/evotecit/Testimo.svg"></a>
  <a href="https://github.com/EvotecIT/Testimo"><img src="https://img.shields.io/powershellgallery/dt/Testimo.svg"></a>
</p>

<p align="center">
  <a href="https://twitter.com/PrzemyslawKlys"><img src="https://img.shields.io/twitter/follow/PrzemyslawKlys.svg?label=Twitter%20%40PrzemyslawKlys&style=social"></a>
  <a href="https://evotec.xyz/hub"><img src="https://img.shields.io/badge/Blog-evotec.xyz-2A6496.svg"></a>
  <a href="https://www.linkedin.com/in/pklys"><img src="https://img.shields.io/badge/LinkedIn-pklys-0077B5.svg?logo=LinkedIn"></a>
</p>

# Testimo - PowerShell Module

## Goals

Testimo is an **alpha product**. That means I change things daily, without warning. I'm playing with few approaches for testing Infrastructrure, including Active Directory. At the moment most tests are for Active Directory only.
Based on [Active Directory CheckList](https://github.com/mczerniawski/Active-Directory-CheckList) and some more. Feel free to submit your own ideas either via Issues or direct PR.

Things to know:
- [x] Currently there's no user exposed configuration - only internal one. It will be added later on.
- [x] Currently all tests are enabled when used from PowerShellGallery, on GitHub it may be 50 / 50
- [x] Configuration hash is not written in stone and can change rapidly
- [x] Ideas are VERY welcome
- [x] There's a big mess in files/function names - I'm still testing things out creating some random stuff

To do tests I use modules that I own, often using internal, not documented functions:

- [x] [PSSharedGoods](https://github.com/EvotecIT/PSSharedGoods)
- [x] [PSWinDocumentation.AD](https://github.com/EvotecIT/PSWinDocumentation.AD)
- [x] [PSWinDocumentation.DNS](https://github.com/EvotecIT/PSWinDocumentation.DNS)
- [x] [ADEssentials](https://github.com/EvotecIT/ADEssentials)


## TODO

- Loading configuration
- Saving configuration
- More tests
- More flexibility

### Legend
---
- DC = Domain Controller
- PrivAccounts = Privileged Accounts [Docs.Microsoft.com](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/appendix-b--privileged-accounts-and-groups-in-active-directory)
- PrivGroups = Privileged Groups [Docs.Microsoft.com](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/appendix-b--privileged-accounts-and-groups-in-active-directory)
- FSMO = Flexible Single-Master Operation
- PDC = Domain Controller with PDC Emulator FSMO role
- `{Services}` = services required by a DC to function properly - `'Active Directory Domain Services','Active Directory Web Services''DFS Replication','DNS Client', 'DNS server','Group Policy Client','Intersite Messaging','Kerberos Key Distribution Center','NetLogon','Windows Time','Workstation'`
- RODC = Read Only Domain Controller
- `{DNS entries}` =
    - _ldap in `{SiteName}._sites.dc._msdcs.contoso.com`
    - _kerberos `{SiteName}._sites.dc._msdcs.contoso.com`
    - _ldap in `_tcp.dc._msdcs.contoso.com`
    - _kerberos in `_tcp.dc._msdcs.contoso.com`
    - _ldap in `{domain-guid].domains._msdcs.contoso.com`
    - record type A in `gc._msdcs.contoso.com`
    - _ldap in `_tcp.{SiteName}._sites.gc._msdcs.contoso.com`
    - _ldap in `_tcp.gc._msdcs.contoso.com`
    - _ldap for PDC in `_tcp.pdc._msdcs.contoso.com`
---

### Actions

Following action, that have **Status** `Tested` are verified and working.
Keep in mind not all tests apply to each environment.
I'm adding those to be flexible and be able to test things as needed.
Each of those tests will need additional description and recommendation.
Some of the tests are very basic and will need feedback, work on making it a robust test.

| Type              | Name                                                   | Area             | Description                                                                                  | Status          | Details                                                             |
| ----------------- | ------------------------------------------------------ | ---------------- | -------------------------------------------------------------------------------------------- | --------------- | ------------------------------------------------------------------- |
| Forest            | Forest Backup                                          | Backup           | Verify `last backup time should be [less than X days]`                                       | Tested          |                                                                     |
| Forest            | Forest Replication                                     | Connectivity     | Verify each `DC in replication site can [reach other replication members]`                   | Tested          |                                                                     |
| Forest            | Optional Features                                      | Features         | Verify Optional Feature `Recycle Bin should be [Enabled]`                                    | Tested          | If domain 2008 R2                                                   |
| Forest            | Optional Features                                      | Features         | Verify Optional Feature `Privileged Access Management Feature should be [Enabled]`           | Tested          | If domain 2016 - checks all for now.                                |
| Forest            |                                                        | Features         | Verify Optional Feature `Bitlocker allows storing recovery key in AD should be [Configured]` | Not implemented |                                                                     |
| Forest            | Optional Features                                      | Features         | Verify Optional Feature `Laps should be enabled [Configured]`                                | Tested          |                                                                     |
| Forest            | Sites Verification                                     | Sites            | Verify each `site has at least [one subnet configured]`                                      | Tested          |                                                                     |
| Forest            | Sites Verification                                     | Sites            | Verify each `site has at least [one domain controller configured]`                           | Tested          |                                                                     |
| Forest            | Site Links                                             | Site Links       | Verify each `site link is automatic`                                                         | Tested          |                                                                     |
| Forest            | Site Links                                             | Site Links       | Verify each `site link uses notifications`                                                   | Tested          |                                                                     |
| Forest            | Site Links                                             | Site Links       | Verify each `site link do not use notification`                                              | Tested          |                                                                     |
| Forest            | Roles availability                                     | FMSO             | Verify each `FSMO holder is [reachable]`                                                     | Tested          |                                                                     |
| Domain            | Password Complexity Requirements                       | Password         | Verify Password `Complexity Policy should be [Enabled]`                                      | Tested          |                                                                     |
| Domain            | Password Complexity Requirements                       | Password         | Verify Password `Length should be [greater than X]`                                          | Tested          |                                                                     |
| Domain            | Password Complexity Requirements                       | Password         | Verify Password `Threshold should be [greater than X]`                                       | Tested          |                                                                     |
| Domain            | Password Complexity Requirements                       | Password         | Verify Password `Lockout Duration should be [greater than X minutes]`                        | Tested          |                                                                     |
| Domain            | Password Complexity Requirements                       | Password         | Verify Password `Lockout Observation Window should be [greater than X minutes]`              | Tested          |                                                                     |
| Domain            | Password Complexity Requirements                       | Password         | Verify Password `Minimum Age should be [greater than X]`                                     | Tested          |                                                                     |
| Domain            | Password Complexity Requirements                       | Password         | Verify Password `History Count should be [greater than X]`                                   | Tested          |                                                                     |
| Domain            | Password Complexity Requirements                       | Password         | Verify Password `Reversible Encryption should be [Disabled]`                                 | Tested          |                                                                     |
| Domain            | Trust Availability                                     | Connectivity     | Verify each `Trust status is OK`                                                             | Tested          |                                                                     |
| Domain            | Trust Unconstrained TGTDelegation                      | Security         | Verify each `Trust TGTDelegation is set to True`                                             | Tested          |                                                                     |
| Domain            | Kerberos Account Age                                   | Security         | Verify `Kerberos Last Password Change Should be less than 180 days`                          | Tested          |                                                                     |
| Domain            | Groups: Account Operators                              | Security         | Verify `Group is empty`                                                                      | Tested          |                                                                     |
| Domain            | User: Administrator                                    | Security         | Verify `Last Password Change should be less than 360 days or account disabled`               | Tested          |                                                                     |
| Domain            |                                                        | PrivAccounts     | Verify Privileged Groups `contains only desired members`                                     | Not implemented |                                                                     |
| Domain            |                                                        | PrivAccounts     | Verify Privileged Users permissions `are set to defaults`                                    | Not implemented |                                                                     |
| Domain            | DNS Forwarders                                         | DNS              | Verify `DNS Forwarders are identical on all DNS nodes`                                       | Tested          | Checks all up nodes/skips down ones.                                |
| Domain            | DNS Scavenging - Primary DNS Server                    | DNS              | Verify `DNS Scavenging is set to [X days]`                                                   | Tested          |                                                                     |
| Domain            | DNS Scavenging - Primary DNS Server                    | DNS              | Verify `DNS Scavenging State is set to True`                                                 | Tested          |                                                                     |
| Domain            | DNS Scavenging - Primary DNS Server                    | DNS              | Verify `DNS Scavenging Time is less than [X days]`                                           | Tested          |                                                                     |
| Domain            |                                                        | DNS              | Verify `{DNS entries} in _msdcs zone [point to all DCs]`                                     | Not implemented |                                                                     |
| Domain            |                                                        | DNS              | Verify `DNS Reverse Lookup zones are [configured for all site subnets]`                      | Not implemented |                                                                     |
| Domain            |                                                        | DHCP             | Verify at least `one DHCP is [authorized in domain]`                                         | Not implemented | If other DHCP than domain integrated is used this should be skipped |
| Domain            | Roles availability                                     | FMSO             | Verify each `FSMO holder is [reachable]`                                                     | Tested          |                                                                     |
| Domain            | Well known folder - UsersContainer                     | WellKnownFolders | Verify `folder is not at it's defaults.`                                                     | Tested          |                                                                     |
| Domain            | Well known folder - ComputersContainer                 | WellKnownFolders | Verify `folder is not at it's defaults.`                                                     | Tested          |                                                                     |
| Domain            | Well known folder - DomainControllersContainer         | WellKnownFolders | Verify `folder is at it's defaults. `                                                        | Tested          |                                                                     |
| Domain            | Well known folder - DeletedObjectsContainer            | WellKnownFolders | Verify `folder is at it's defaults.`                                                         | Tested          |                                                                     |
| Domain            | Well known folder - SystemsContainer                   | WellKnownFolders | Verify `folder is at it's defaults. `                                                        | Tested          |                                                                     |
| Domain            | Well known folder - LostAndFoundContainer              | WellKnownFolders | Verify `folder is at it's defaults.`                                                         | Tested          |                                                                     |
| Domain            | Well known folder - QuotasContainer                    | WellKnownFolders | Verify `folder is at it's defaults.`                                                         | Tested          |                                                                     |
| Domain            | Well known folder - ForeignSecurityPrincipalsContainer | WellKnownFolders | Verify `folder is at it's defaults.`                                                         | Tested          |                                                                     |
| Domain Controller | Ping Connectivity                                      | Connectivity     | Verify `DC is [reachable]`                                                                   | Tested          |                                                                     |
| Domain Controller | Service Status                                         | Services         | Verify all `{Services} are [running]`                                                        | Tested          | Needs rework                                                        |
| Domain Controller | Service Status                                         | Services         | Verify all `{Services} are set to [automatic startup]`                                       | Tested          | Needs rework                                                        |
| Domain Controller | LDAP Connectivity                                      | Connectivity     | Verify all `{LDAP Ports} are open]`                                                          | Tested          |                                                                     |
| Domain Controller | LDAP Connectivity                                      | Connectivity     | Verify all `{LDAP SSL Ports} are open]`                                                      | Tested          |                                                                     |
| Domain Controller | Resolves internal DNS queries                          | DNS              | Verify `DNS on DC [resolves Internal DNS]`                                                   | Tested          | Resolve $Domain, requires to match ALL DC's IPV4                    |
| Domain Controller | Resolves external DNS queries                          | DNS              | Verify `DNS on DC [resolves External DNS]`                                                   | Tested          | Resolve evotec.xyz - requires to match IPV4                         |
| Domain Controller | Name servers for primary domain zone                   | DNS              | Verify `DNS Name servers for primary zone are identical`                                     | Tested          |                                                                     |
| Domain Controller | Responds to PowerShell Queries                         | PowerShell       | Verify DC `responds to PowerShell queries`                                                   | Tested          |                                                                     |
| Domain Controller | Ports                                                  | Connectivity     | Verify `Following ports 53, 88, 135, 139, 389, 445, 464, 636, 3268, 3269, 9389 are open`     | Tested          |                                                                     |
| Domain Controller | Ports RDP                                              | Connectivity     | Verify `Following ports 3389 (RDP) is open`                                                  | Tested          |                                                                     |
| Domain Controller |                                                        | Time             | Verify `PDC should [sync time to external source]`                                           |                 |                                                                     |
| Domain Controller |                                                        | Time             | Verify `Non-PDC should [sync time to PDC emulator]`                                          |                 |                                                                     |
| Domain Controller |                                                        | Time             | Verify `Virtualized DCs should [sync to hypervisor during boot time only]`                   |                 |                                                                     |
| Domain Controller | Time Synchronization Internal                          | Time             | Verify `Time Synchronization Difference to PDC [less than X seconds]`                        | Tested          |                                                                     |
| Domain Controller | Time Synchronization External                          | Time             | Verify `Time Synchronization Difference to pool.ntp.org [less than X seconds]`               | Tested          |                                                                     |
| Domain Controller | Disk Free                                              | Computer         | Verify `OS partition Free space is [at least X %]`                                           | Tested          | Partially - tests all drives                                        |
| Domain Controller | Disk Free                                              | Computer         | Verify `NTDS partition Free space is [at least X %]`                                         | Tested          | Partially - tests all drives                                        |
| Domain Controller | Windows Firewall                                       | Connectivity     | Verify `windows firewall is enabled` for all network cards                                   | Tested          |                                                                     |
| Domain Controller | Windows Remote Management                              | Connectivity     | Verify `Windows Remote Management identification requests are managed`                       | Tested          |                                                                     |
| Domain Controller | Operating System                                       | Computer         | Verify `Windows Operating system is Windows 2012 or higher`                                  | Tested          |                                                                     |
| Domain Controller | Windows Updates                                        | Computer         | Verify `Last patch was installed less than 60 days ago`                                      | Tested          |                                                                     |

### Things to consider

- Criticality of Tests - some tests are critical, some are less critical
- Recommended, Default, Sane - not all tests are equal or make sense in all conditions

## To install

```powershell
Install-Module -Name Testimo -AllowClobber -Force
```

Force and AllowClobber aren't really nessecary but they do skip errors in case some appear.

### And to update

```powershell
Update-Module -Name Testimo
```

That's it. Whenever there's new version you simply run the command and you can enjoy it. Remember, that you may need to close, reopen PowerShell session if you have already used module before updating it.

**The important thing** is if something works for you on production, keep using it till you test the new version on a test computer. I do changes that may not be big, but big enough that auto-update will break your code. For example, small rename to a parameter and your code stops working! Be responsible!

### To use after installation

With output to screen only

```powershell
Test-Imo
```

With option to be able to process output - for example to email

```powershell
Test-Imo -ReturnResults
```