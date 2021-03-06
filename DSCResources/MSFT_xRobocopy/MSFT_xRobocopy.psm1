function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Source,

        [parameter(Mandatory = $true)]
        [System.String]
        $Destination,

        [System.String]
        $LogOutput
    )

    $LogOutputExists = Test-Path $PSBoundParameters.LogOutput

    $returnValue = @{
        Source = if (test-path $Source){[System.String]$(ls $Source).psChildName};
        Destination = if (test-path $Destination){[System.String]$(ls $Destination).psChildName};
        LogOutput = if ($LogOutputExists -eq $true){[System.String]$PSBoundParameters.LogOutput}
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Source,

        [parameter(Mandatory = $true)]
        [System.String]
        $Destination,

        [System.String]
        $Files,

        [System.UInt32]
        $Retry,

        [System.UInt32]
        $Wait,

        [System.Boolean]
        $SubdirectoriesIncludingEmpty,

        [System.Boolean]
        $Restartable,

        [System.Boolean]
        $MultiThreaded,

        [System.String]
        $ExcludeFiles,

        [System.String]
        $LogOutput,

        [System.Boolean]
        $AppendLog,

        [System.String]
        $AdditionalArgs
    )

    [string]$Arguments = ''
    if ($Retry -ne '') {$Arguments += " /R:$PSBoundParameters:Retry"}
    if ($Wait -ne '') {$Arguments += " /W:$PSBoundParameters:Wait"}
    if ($SubdirectoriesIncludingEmpty -ne '') {$Arguments += ' /E'}
    if ($Restartable -ne '') {$Arguments += ' /MT'}
    if ($ExcludeFiles -ne '') {$Arguments += " /XF $PSBoundParameters:ExludeFiles"}
    if ($ExcludeDirs -ne '') {$Arguments += " /XD $PSBoundParameters:ExcludeDirs"}
    if ($LogOutput -ne '' -AND $AppendLog -eq $true) {
        $Arguments += " /LOG+:$PSBoundParameters:LogOutput"
        }
    if ($LogOutput -ne '' -AND $AppendLog -eq $false) {
        $Arguments += " /LOG:$PSBoundParameters:LogOutput"
     }
    if ($AdditionalArgs -ne $null) {$Arguments += " $PSBoundParameters:AdditionalArgs"}

    try {
        Write-Verbose "Executing Robocopy with arguements: $arguements"
        Invoke-Robocopy $Source $Destination $Arguments
        }
    catch {
        Write-Warning "An error occured executing Robocopy.exe.  ERROR: $_"
        }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Source,

        [parameter(Mandatory = $true)]
        [System.String]
        $Destination,

        [System.String]
        $Files,

        [System.UInt32]
        $Retry,

        [System.UInt32]
        $Wait,

        [System.Boolean]
        $SubdirectoriesIncludingEmpty,

        [System.Boolean]
        $Restartable,

        [System.Boolean]
        $MultiThreaded,

        [System.String]
        $ExcludeFiles,

        [System.String]
        $LogOutput,

        [System.Boolean]
        $AppendLog,

        [System.String]
        $AdditionalArgs
    )

    try {
        $result = Invoke-RobocopyTest $Source $Destination
        }
    catch {
        Write-Warning "An error occured while getting the file list from Robocopy.exe.  ERROR: $_"
        }
    
    if ($result -eq 0) {[system.boolean]$result = $true}
     else {[system.boolean]$result = $false}
    
    $result
}

# Helper Functions

function Invoke-RobocopyTest {
param (
    [parameter(Mandatory = $true)]
    [System.String]
    $source,

    [parameter(Mandatory = $true)]
    [System.String]
    $destination
)
    $output = & robocopy.exe /L $source $destination
    $LASTEXITCODE
}
 # Invoke-RobocopyTest C:\DSCTestMOF C:\DSCTestMOF2

function Invoke-Robocopy {
param (
    [parameter(Mandatory = $true)]
    [System.String]
    $source,

    [parameter(Mandatory = $true)]
    [System.String]
    $destination,

    [System.String]
    $Arguments
)

    # This is a safe use of invoke-expression.  Input is only passed as parameters to Robocopy.exe, it cannot be executed directly
    $output = Invoke-Expression "Robocopy.exe $Source $Destination $Arguments"

    $LASTEXITCODE
}
 # Invoke-Robocopy -source C:\DSCTestMOF -destination C:\DSCTestMOF2 -Arguments '/E /MT'

Export-ModuleMember -Function *-TargetResource