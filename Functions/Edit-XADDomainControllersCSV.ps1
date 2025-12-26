function Edit-XADDomainControllersCSV {
    [CmdletBinding()]
    param()

    $ParentFolder = Split-Path $PSScriptRoot
    $DataFolder = Join-Path $ParentFolder 'Data'
    $CsvPath = "$DataFolder\Domain_Controllers_IPs.csv"

    # Load the CSV
    $CsvData = Import-Csv $CsvPath

    $Modified = $false

    :EditMenu while ($true) {
        Clear-Host
        Write-Host "Domain Controllers CSV Editor" -ForegroundColor Cyan
        Write-Host "Current entries:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $CsvData.Count; $i++) {
            Write-Host "$($i+1). Domain: $($CsvData[$i].Domain), IP: $($CsvData[$i].IP)"
        }
        Write-Host ""

        $Choices = @('Add Entry', 'Remove Entry', 'Modify Entry', 'Save Changes', 'Exit')
        $Option = Show-XADMenu -Title 'Choose an action' -Choices $Choices

        switch ($Option) {
            1 { # Add Entry
                $Domain = Read-Host "Enter Domain name"
                $IP = Read-Host "Enter IP address"
                if ($Domain -and $IP) {
                    $NewEntry = [PSCustomObject]@{
                        Domain = $Domain
                        IP = $IP
                    }
                    $CsvData += $NewEntry
                    $Modified = $true
                    Write-Host "Entry added." -ForegroundColor Green
                } else {
                    Write-Host "Invalid input. Both Domain and IP are required." -ForegroundColor Red
                }
                Read-Host "Press Enter to continue"
            }
            2 { # Remove Entry
                if ($CsvData.Count -eq 0) {
                    Write-Host "No entries to remove." -ForegroundColor Red
                    Read-Host "Press Enter to continue"
                    continue
                }
                $Index = Read-Host "Enter the number of the entry to remove (1-$($CsvData.Count))"
                try {
                    $Idx = [int]$Index - 1
                    if ($Idx -ge 0 -and $Idx -lt $CsvData.Count) {
                        $CsvData = $CsvData | Where-Object { $_ -ne $CsvData[$Idx] }
                        $Modified = $true
                        Write-Host "Entry removed." -ForegroundColor Green
                    } else {
                        Write-Host "Invalid index." -ForegroundColor Red
                    }
                } catch {
                    Write-Host "Invalid input." -ForegroundColor Red
                }
                Read-Host "Press Enter to continue"
            }
            3 { # Modify Entry
                if ($CsvData.Count -eq 0) {
                    Write-Host "No entries to modify." -ForegroundColor Red
                    Read-Host "Press Enter to continue"
                    continue
                }
                $Index = Read-Host "Enter the number of the entry to modify (1-$($CsvData.Count))"
                try {
                    $Idx = [int]$Index - 1
                    if ($Idx -ge 0 -and $Idx -lt $CsvData.Count) {
                        $CurrentDomain = $CsvData[$Idx].Domain
                        $CurrentIP = $CsvData[$Idx].IP
                        Write-Host "Current: Domain: $CurrentDomain, IP: $CurrentIP"
                        $NewDomain = Read-Host "Enter new Domain name (leave blank to keep '$CurrentDomain')"
                        $NewIP = Read-Host "Enter new IP address (leave blank to keep '$CurrentIP')"
                        if ($NewDomain) { $CsvData[$Idx].Domain = $NewDomain }
                        if ($NewIP) { $CsvData[$Idx].IP = $NewIP }
                        $Modified = $true
                        Write-Host "Entry modified." -ForegroundColor Green
                    } else {
                        Write-Host "Invalid index." -ForegroundColor Red
                    }
                } catch {
                    Write-Host "Invalid input." -ForegroundColor Red
                }
                Read-Host "Press Enter to continue"
            }
            4 { # Save Changes
                if ($Modified) {
                    try {
                        $CsvData | Export-Csv -Path $CsvPath -NoTypeInformation
                        Write-Host "Changes saved." -ForegroundColor Green
                        $Modified = $false
                    } catch {
                        Write-Host "Error saving file: $_" -ForegroundColor Red
                    }
                } else {
                    Write-Host "No changes to save." -ForegroundColor Yellow
                }
                Read-Host "Press Enter to continue"
            }
            0 { # Exit
                if ($Modified) {
                    $SaveChoice = Read-Host "You have unsaved changes. Save before exiting? (y/n)"
                    if ($SaveChoice -eq 'y') {
                        try {
                            $CsvData | Export-Csv -Path $CsvPath -NoTypeInformation
                            Write-Host "Changes saved." -ForegroundColor Green
                        } catch {
                            Write-Host "Error saving file: $_" -ForegroundColor Red
                        }
                    }
                }
                break EditMenu
            }
        }
    }
}