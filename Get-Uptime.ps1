<#
.Synopsis
    Get-Uptime will return the uptime of a given server in either Days, Hours, Minutes, or Seconds.
.DESCRIPTION
    Get-Uptime will return the uptime of a given server in either Days, Hours, Minutes, or Seconds. The default TimeSpan is Days, and credentials may be passed.
.EXAMPLE
    Get-Uptime -ComputerName ca1cluster1n3,ca1cluster1n4
    Will return the uptime for ca1cluster1n3 and ca1cluster1n4 in days.
.EXAMPLE
    Get-Uptime -ComputerName ca1cluster1n3,ca1cluster1n4 -TimeSpan Hours -Credential $(Get-Credential)
    Will return the uptime for ca1cluster1n3 and ca1cluster1n4 in hours. The connection to the given computers will be authenticated with the given credentials.
#>
function Get-Uptime
{
    [CmdletBinding()]
    [Alias('uptime')]
    Param
    (
    [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
    [String[]]$ComputerName,

    [Parameter(Mandatory=$false)]
    [ValidateSet('Days','Minutes','Hours','Seconds')]
    [String]$TimeSpan = 'Days',

    [Parameter(Mandatory=$false)]
    [PSCredential] $Credential
    )
    Begin
    {
        $f = "[$($MyInvocation.MyCommand.Name)]"
        $outArray = New-Object System.Collections.Generic.List[Object]
    }
    Process
    {
        foreach ( $Computer in $ComputerName )
        {

            Try
            {
                $Params = @{
                    ClassName = 'Win32_OperatingSystem'
                    ErrorAction = 'Stop'
                }

                if ( $Credential ) {
                    Write-Verbose "$f`: Attempting to connect to $computer with Credentials"
                    $cimSession = New-CimSession -Credential $Credential -ComputerName $Computer -ErrorAction Stop

                    Write-Verbose "$f`: Successfully connected to $computer with Credentials"

                    $Params.CimSession = $cimSession

                    Write-Verbose "$f`: Attempting to get CIMInstance Win32_OperatingSystem from $computer"
                    $cimInstance = Get-CimInstance @Params
                }
                else {
                    Write-Verbose "$f`: Attempting to get CIMInstance Win32_OperatingSystem from $computer"
                    $params.ComputerName = $Computer
                    $cimInstance = Get-CimInstance @Params
                }

                $upTime = $(Get-Date) - $($cimInstance.LastBootUpTime)

                switch ( $TimeSpan ) {
                    'Days' {
                        $outObj = [PSCustomObject]@{
                            ComputerName = $Computer
                            Days = $uptime.Days
                        }
                    }
                    'Hours' {
                        Write-Verbose "$f`: Attempting to get CIMInstance Win32_OperatingSystem from $computer"
                        $outObj = [PSCustomObject]@{
                            ComputerName = $Computer
                            Hours = $( $($uptime.Days * 24) + $uptime.Hours )
                        }
                    }
                    'Minutes' {
                        $outObj = [PSCustomObject]@{
                            ComputerName = $Computer
                            Minutes = $( $($uptime.Days * 1440) + $($uptime.Hours * 60) + $uptime.Minutes )
                        }
                    }
                    'Seconds' {
                        $outObj = [PSCustomObject]@{
                            ComputerName = $Computer
                            Seconds = $( $($uptime.Days * 86400) + $($uptime.Hours * 3600) + $uptime.Seconds )
                        }
                    }
                }

                $outArray.Add($outObj)
            }
            Catch
            {
                Write-Error "$f`: Failed to Connect to $Computer"
                switch ( $TimeSpan ) {
                    'Days' {
                        $outObj = [PSCustomObject]@{
                            ComputerName = $Computer
                            Days = "Failed to Connect to $Computer"
                        }
                    }
                    'Hours' {
                        Write-Verbose "$f`: Attempting to get CIMInstance Win32_OperatingSystem from $computer"
                        $outObj = [PSCustomObject]@{
                            ComputerName = $Computer
                            Hours = "Failed to Connect to $Computer"
                        }
                    }
                    'Minutes' {
                        $outObj = [PSCustomObject]@{
                            ComputerName = $Computer
                            Minutes = "Failed to Connect to $Computer"
                        }
                    }
                    'Seconds' {
                        $outObj = [PSCustomObject]@{
                            ComputerName = $Computer
                            Seconds = "Failed to Connect to $Computer"
                        }
                    }
                }
                $outArray.Add($outObj)
            }


        }
    }
    End
    {
        Write-Output $outArray
    }
}