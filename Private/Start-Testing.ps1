﻿function Start-Testing {
    [CmdletBinding()]
    param(
        [ScriptBlock] $Execute,
        [string] $Scope,
        [string] $Domain,
        [string] $DomainController,
        [bool] $IsPDC,
        [Object] $ForestInformation,
        [Object] $DomainInformation
    )
    $GlobalTime = Start-TimeLog

    if ($Scope -eq 'Forest') {
        $Level = 3
        $LevelTest = 6
        $LevelSummary = 3
        $LevelTestFailure = 6
    } elseif ($Scope -eq 'Domain') {
        $Level = 6
        $LevelTest = 9
        $LevelSummary = 6
        $LevelTestFailure = 9
    } elseif ($Scope -eq 'DomainControllers') {
        $Level = 9
        $LevelTest = 12
        $LevelSummary = 9
        $LevelTestFailure = 12
    } else {

    }

    if ($Domain -and $DomainController) {
        $SummaryText = "Domain $Domain, $DomainController"
    } elseif ($Domain) {
        Write-Color
        $SummaryText = "Domain $Domain"
    } else {
        $SummaryText = "Forest"
    }

    # Build requirements variables
    [bool] $IsDomainRoot = $ForestInformation.Name -eq $Domain


    # Out-Begin -Type 'i' -Text $SummaryText -Level ($LevelSummary - 3) -Domain $Domain -DomainController $DomainController
    # Out-Status -Text $SummaryText -Status $null -ExtendedValue '' -Domain $Domain -DomainController $DomainController

    Out-Informative -Text $SummaryText -Status $null -ExtendedValue '' -Domain $Domain -DomainController $DomainController  -Level ($LevelSummary - 3)

    $TestsSummaryTogether = @(
        foreach ($Source in $($Script:TestimoConfiguration.$Scope.Keys)) {
            $CurrentSection = $Script:TestimoConfiguration.$Scope[$Source]
            if ($null -eq $CurrentSection) {
                # Probably should write some tests
                Write-Warning "Source $Source in scope: $Scope is defined improperly. Please verify."
                continue
            }
            if ($CurrentSection['Enable'] -eq $true) {
                $Time = Start-TimeLog
                $CurrentSource = $CurrentSection['Source']
                [Array] $AllTests = $CurrentSection['Tests'].Keys

                $ReferenceID = $Source #Get-RandomStringName -Size 8
                $TestsSummary = [PSCustomobject] @{
                    Passed  = 0
                    Failed  = 0
                    Skipped = 0
                    Total   = 0 # $AllTests.Count + 1 # +1 includes availability of data test
                }
                # build data output for extended results

                if ($Domain -and $DomainController) {
                    $Script:Reporting['Domains'][$Domain]['DomainControllers'][$DomainController]['Tests'][$ReferenceID] = [ordered] @{
                        Name             = $CurrentSource['Name']
                        SourceCode       = $CurrentSource['Data']
                        Details          = $CurrentSource['Details']
                        Results          = [System.Collections.Generic.List[PSCustomObject]]::new()
                        Domain           = $Domain
                        DomainController = $DomainController
                    }
                } elseif ($Domain) {
                    $Script:Reporting['Domains'][$Domain]['Tests'][$ReferenceID] = [ordered] @{
                        Name             = $CurrentSource['Name']
                        SourceCode       = $CurrentSource['Data']
                        Details          = $CurrentSource['Details']
                        Results          = [System.Collections.Generic.List[PSCustomObject]]::new()
                        Domain           = $Domain
                        DomainController = $DomainController
                    }
                } else {
                    $Script:Reporting['Forest']['Tests'][$ReferenceID] = [ordered] @{
                        Name             = $CurrentSource['Name']
                        SourceCode       = $CurrentSource['Data']
                        Details          = $CurrentSource['Details']
                        Results          = [System.Collections.Generic.List[PSCustomObject]]::new()
                        Domain           = $Domain
                        DomainController = $DomainController
                    }
                }

                if (-not $CurrentSection['Source']) {
                    Write-Warning "Source $Source in scope: $Scope is defined improperly. Please verify."
                    continue
                }

                # Check if requirements are met
                if ($CurrentSource['Requirements']) {
                    if ($null -ne $CurrentSource['Requirements']['IsDomainRoot']) {
                        if (-not $CurrentSource['Requirements']['IsDomainRoot'] -eq $IsDomainRoot) {
                            Out-Skip -Test $CurrentSource['Name'] -DomainController $DomainController `
                                -Domain $Domain -TestsSummary $TestsSummary -Source $ReferenceID -Level $Level
                            continue
                        }
                    }
                    if ($null -ne $CurrentSource['Requirements']['IsPDC']) {
                        if (-not $CurrentSource['Requirements']['IsPDC'] -eq $IsPDC) {
                            Out-Skip -Test $CurrentSource['Name'] -DomainController $DomainController `
                                -Domain $Domain -TestsSummary $TestsSummary -Source $ReferenceID -Level $Level
                            continue
                        }
                    }
                    if ($null -ne $CurrentSource['Requirements']['OperatingSystem']) {


                    }
                    if ($null -ne $CurrentSource['Requirements']['CommandAvailable']) {
                        [Array] $Commands = foreach ($Command in $CurrentSource['Requirements']['CommandAvailable']) {
                            $OutputCommand = Get-Command -Name $Command -ErrorAction SilentlyContinue
                            if (-not $OutputCommand) {
                                $false
                            }
                        }
                        if ($Commands -contains $false) {
                            $CommandsTested = $CurrentSource['Requirements']['CommandAvailable'] -join ', '
                            Out-Skip -Test $CurrentSource['Name'] -DomainController $DomainController `
                                -Domain $Domain -TestsSummary $TestsSummary -Source $ReferenceID -Level $Level `
                                -Reason "Skipping - At least one command unavailable ($CommandsTested)"
                            continue
                        }
                    }
                }



                if ($CurrentSource['Parameters']) {
                    $SourceParameters = $CurrentSource['Parameters']
                    $Object = Start-TestProcessing -Test $CurrentSource['Name'] -Level $Level -OutputRequired -Domain $Domain -DomainController $DomainController -ReferenceID $ReferenceID {
                        & $CurrentSource['Data'] @SourceParameters -DomainController $DomainController -Domain $Domain
                    }
                } else {
                    $Object = Start-TestProcessing -Test $CurrentSource['Name'] -Level $Level -OutputRequired -Domain $Domain -DomainController $DomainController -ReferenceID $ReferenceID {
                        & $CurrentSource['Data'] -DomainController $DomainController -Domain $Domain
                    }
                }
                # Add data output to extended results
                if ($Domain -and $DomainController) {
                    $Script:Reporting['Domains'][$Domain]['DomainControllers'][$DomainController]['Tests'][$ReferenceID]['Data'] = $Object
                } elseif ($Domain) {
                    $Script:Reporting['Domains'][$Domain]['Tests'][$ReferenceID]['Data'] = $Object
                } else {
                    $Script:Reporting['Forest']['Tests'][$ReferenceID]['Data'] = $Object
                }
                # If there's no output from Source Data all other tests will fail
                if ($Object -and ($null -eq $CurrentSource['ExpectedOutput'] -or $CurrentSource['ExpectedOutput'] -eq $true)) {
                    # Output is provided and we did expect it or didn't provide expectation
                    $FailAllTests = $false
                    Out-Begin -Text $CurrentSource['Name'] -Level $LevelTest -Domain $Domain -DomainController $DomainController
                    Out-Status -Text $CurrentSource['Name'] -Status $true -ExtendedValue 'Data is available.' -Domain $Domain -DomainController $DomainController -ReferenceID $ReferenceID
                    $TestsSummary.Passed = $TestsSummary.Passed + 1

                } elseif ($Object -and $CurrentSource['ExpectedOutput'] -eq $false) {
                    # Output is provided, but we expected no output - failing test

                    $FailAllTests = $true
                    Out-Failure -Text $CurrentSource['Name'] -Level $LevelTest -ExtendedValue 'Data is available. This is a bad thing.' -Domain $Domain -DomainController $DomainController -ReferenceID $ReferenceID
                    $TestsSummary.Failed = $TestsSummary.Failed + 1

                } elseif ($null -eq $Object -and $CurrentSource['ExpectedOutput'] -eq $false) {
                    # This tests whether there was an output from Source or not.
                    # Sometimes it makes sense to ask for data and get null/empty in return
                    # you just need to make sure to define ExpectedOutput = $false in source definition
                    $FailAllTests = $false
                    Out-Begin -Text $CurrentSource['Name'] -Level $LevelTest -Domain $Domain -DomainController $DomainController
                    Out-Status -Text $CurrentSource['Name'] -Status $true -ExtendedValue 'No data returned, which is a good thing.' -Domain $Domain -DomainController $DomainController -ReferenceID $ReferenceID
                    $TestsSummary.Passed = $TestsSummary.Passed + 1
                } else {
                    $FailAllTests = $true
                    Out-Failure -Text $CurrentSource['Name'] -Level $LevelTest -ExtendedValue 'No data available.' -Domain $Domain -DomainController $DomainController -ReferenceID $ReferenceID
                    $TestsSummary.Failed = $TestsSummary.Failed + 1
                }
                foreach ($Test in $AllTests) {
                    $CurrentTest = $CurrentSection['Tests'][$Test]
                    if ($CurrentTest['Enable'] -eq $True) {
                        # Check for requirements
                        if ($CurrentTest['Requirements']) {
                            if ($null -ne $CurrentTest['Requirements']['IsDomainRoot']) {
                                if (-not $CurrentTest['Requirements']['IsDomainRoot'] -eq $IsDomainRoot) {
                                    $TestsSummary.Skipped = $TestsSummary.Skipped + 1
                                    continue
                                }
                            }
                            if ($null -ne $CurrentTest['Requirements']['IsPDC']) {
                                if (-not $CurrentTest['Requirements']['IsPDC'] -eq $IsPDC) {
                                    $TestsSummary.Skipped = $TestsSummary.Skipped + 1
                                    continue
                                }
                            }
                        }
                        if (-not $FailAllTests) {
                            if ($CurrentTest['Parameters']) {
                                $Parameters = $CurrentTest['Parameters']
                            } else {
                                $Parameters = $null
                            }
                            $TestsResults = Start-TestingTest -Test $CurrentTest['Name'] -Level $LevelTest -Domain $Domain -DomainController $DomainController -ReferenceID $ReferenceID {
                                Test-StepOne -Object $Object -Domain $Domain -DomainController $DomainController @Parameters -Level $LevelTest -TestName $CurrentTest['Name'] -ReferenceID $ReferenceID
                            }
                            $TestsSummary.Passed = $TestsSummary.Passed + ($TestsResults | Where-Object { $_ -eq $true }).Count
                            $TestsSummary.Failed = $TestsSummary.Failed + ($TestsResults | Where-Object { $_ -eq $false }).Count
                        } else {
                            $TestsSummary.Failed = $TestsSummary.Failed + 1
                            Out-Failure -Text $CurrentTest['Name'] -Level $LevelTestFailure -Domain $Domain -DomainController $DomainController -ReferenceID $ReferenceID
                        }
                    } else {
                        $TestsSummary.Skipped = $TestsSummary.Skipped + 1
                    }
                }
                $TestsSummary.Total = $TestsSummary.Failed + $TestsSummary.Passed + $TestsSummary.Skipped
                $TestsSummary
                Out-Summary -Text $CurrentSource['Name'] -Time $Time -Level $LevelSummary -Domain $Domain -DomainController $DomainController -TestsSummary $TestsSummary
            }
        }
        if ($Execute) {
            & $Execute
        }
    )
    $TestsSummaryFinal = [PSCustomObject] @{
        Passed  = ($TestsSummaryTogether.Passed | Measure-Object -Sum).Sum
        Failed  = ($TestsSummaryTogether.Failed | Measure-Object -Sum).Sum
        Skipped = ($TestsSummaryTogether.Skipped | Measure-Object -Sum).Sum
        Total   = ($TestsSummaryTogether.Total | Measure-Object -Sum).Sum
    }
    $TestsSummaryFinal

    if ($Domain -and $DomainController) {
        $Script:Reporting['Domains'][$Domain]['DomainControllers'][$DomainController]['Summary'] = $TestsSummaryFinal
    } elseif ($Domain) {
        $Script:Reporting['Domains'][$Domain]['Summary'] = $TestsSummaryFinal
    } else {
        $Script:Reporting['Summary'] = $TestsSummaryFinal
    }

    Out-Summary -Text $SummaryText -Time $GlobalTime -Level ($LevelSummary - 3) -Domain $Domain -DomainController $DomainController -TestsSummary $TestsSummaryFinal
}