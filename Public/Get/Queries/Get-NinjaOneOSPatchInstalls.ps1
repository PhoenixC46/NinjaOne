function Get-NinjaOneOSPatchInstalls {
    <#
        .SYNOPSIS
            Gets the OS patch installs from the NinjaOne API.
        .DESCRIPTION
            Retrieves the OS patch installs from the NinjaOne v2 API.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Filter devices.
        [Alias('df')]
        [String]$deviceFilter,
        # Monitoring timestamp filter.
        [Alias('ts')]
        [string]$timeStamp,
        # Filter patches by patch status.
        [ValidateSet('FAILED', 'INSTALLED')]
        [String]$status,
        # Filter patches to those installed before this date. 
        [DateTime]$installedBefore,
        # Filter patches to those installed after this date. Unix Epoch time.
        [Int]$installedBeforeUnixEpoch,
        # Filter patches to those installed after this date. PowerShell DateTime object.
        [DateTime]$installedAfter,
        # Filter patches to those installed after this date. Unix Epoch time.
        [Int]$installedAfterUnixEpoch,
        # Cursor name.
        [String]$cursor,
        # Number of results per page.
        [Int]$pageSize
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    if ($installedBefore) {
        [Int]$installedBefore = ConvertTo-UnixEpoch -DateTime $installedBefore
    }
    if ($installedBeforeUnixEpoch) {
        $Parameters.Remove('installedBeforeUnixEpoch') | Out-Null
        [Int]$installedBefore = $installedBeforeUnixEpoch
    }
    if ($installedAfter) {
        [Int]$installedAfter = ConvertTo-UnixEpoch -DateTime $installedAfter
    }
    if ($installedAfterUnixEpoch) {
        $Parameters.Remove('installedAfterUnixEpoch') | Out-Null
        [Int]$installedAfter = $installedAfterUnixEpoch
    }
    try {
        $QSCollection = New-NinjaOneQuery -CommandName $CommandName -Parameters $Parameters
        $Resource = 'v2/queries/os-patch-installs'
        $RequestParams = @{
            Resource = $Resource
            QSCollection = $QSCollection
        }
        $OSPatchInstalls = New-NinjaOneGETRequest @RequestParams
        Return $OSPatchInstalls
    } catch {
        New-NinjaOneError -ErrorRecord $_
    }
}