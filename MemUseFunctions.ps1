function Get-ProcessMemory {
    [CmdletBinding(DefaultParameterSetName = 'None')]
    [OutputType([PSCustomObject])]

    param (
        # Remote computer or collection of remote computers
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'CN')]
        [string[]]
        $ComputerName,

        # PSCredential for remote computer(s)
        [Parameter(ParameterSetName = 'CN')]
        [pscredential]
        $Credential,

        # PSSession for remote connection
        [Parameter(Mandatory = $true, ParameterSetName = 'Session')]
        [System.Management.Automation.Runspaces.PSSession]
        $Session
    )
       
    process {
        $Command = @'
            Get-Process |
                Tee-Object -Variable Procs |
                    Group-Object Name, path |
                        Select-Object @{
                                        n="ProcName"
                                        e={($_.name -split ", ")[0]}
                                    },
                                    @{
                                        n="Path"
                                        e={($_.name -split ", ")[-1]}
                                    },
                                    @{
                                        n="TotalProcs"
                                        e={$_.Count}
                                    }, 
                                    @{
                                        n="WorkingSetTotal"
                                        e={($_.Group.WorkingSet | Measure-Object -Sum).sum}
                                    },
                                    @{
                                        n="Percentage"
                                        e={($_.Group.WorkingSet | Measure-Object -Sum).sum / 
                                            ($Procs.workingset | Measure-Object -Sum).Sum 
                                        }
                                    }
'@ #Command here-string to invoke
        if ($PSCmdlet.ParameterSetName -eq "None") {
            Invoke-Expression -Command $Command
        } #if ParameterSetName is None (local machine)
        
        else {
            $InvokeCommandArgs = $PSBoundParameters #works because I use the same parameter names
            $InvokeCommandArgs.ScriptBlock = [scriptblock]::Create($Command)
            Invoke-Command @InvokeCommandArgs
        } #else - ParameterSetName is NOT None (remoting)   

    } #Process Script Block for Get-ProcessMemory Function 

} #Get-ProcessMemory Function Definition

function Show-ProcessMemory {
    [CmdletBinding(DefaultParameterSetName = 'None')]

    param (
        # Remote computer or collection of remote computers
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'CN')]
        [string[]]
        $ComputerName,

        # PSCredential for remote computer(s)
        [Parameter(ParameterSetName = 'CN')]
        [pscredential]
        $Credential,

        # PSSession for remote connection
        [Parameter(Mandatory = $true, ParameterSetName = 'Session')]
        [System.Management.Automation.Runspaces.PSSession]
        $Session
    )
    
    process {
        
        Get-ProcessMemory @PSBoundParameters |
            Sort-Object WorkingSetTotal -Descending |
                Format-Table -Property @{
                                            n="Name"
                                            e={$_.ProcName}
                                            w=35
                                        },
                                        @{
                                            n="Path"
                                            e={$_.Path}
                                            w=30
                                        },
                                        @{
                                            n="Procesess"
                                            e={$_.TotalProcs}
                                            w=10
                                        },
                                        @{
                                            n="Usage/MB"
                                            e={$_.WorkingSetTotal / 1MB}
                                            f="N2"
                                            w=15
                                        },
                                        @{
                                            n="Percentage"
                                            e={$_.Percentage}
                                            f="P2"
                                            w=15
                                        }
        
    } #Process Script Block for Show-ProcessMemory Function
    
} #Show-ProcessMemory Function Definition
