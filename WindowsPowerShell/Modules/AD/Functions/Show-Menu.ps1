<#
.SYNOPSIS
    Display a numbered menu and return the selected choice as an integer.

.DESCRIPTION
    Renders a simple text menu to the host with a title and list of choices.
    Prompts the user to enter a numeric selection (1..N). Returns the selected
    menu item number, or 0 if no valid selection was made.

.PARAMETER Title
    Title text to display above the menu. Defaults to 'Menu'.

.PARAMETER Choices
    Array of strings representing the menu entries.

.EXAMPLE
    $Choice = Show-Menu -Title 'Actions' -Choices @('Create','Delete','Exit')

.EXAMPLE
    @('Option1', 'Option2') | Show-Menu -Title 'Select Option'

.OUTPUTS
    System.Int32

.NOTES
    Version 1.0.0
#>
function Show-Menu {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(
            Position = 0
        )]
        [string]$Title = 'Menu',

        [Parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true
        )]
        [string[]]$Choices
    )
    $SelectedChoice = 0
    Write-Host "$Title" -ForegroundColor Cyan
    Write-Host "-------------------------------"
    $i = 1
    foreach ($Choice in $Choices) {
        $RandomColor = Get-Random -Minimum 1 -Maximum 15
        Write-Host "$i. $Choice" -ForegroundColor $RandomColor
        $i++
    }
    Write-Host "-------------------------------"
    try {
        [int]$SelectedChoice = Read-Host "`nEnter your choice (1-$($Choices.Count)) or type anything else to quit"
    }
    catch {
        $SelectedChoice = 0
        $SelectedChoice
        Return
    }
    if  ($SelectedChoice -lt 1 -or $SelectedChoice -gt $Choices.Count){
        $SelectedChoice = 0
    }
    $SelectedChoice
}