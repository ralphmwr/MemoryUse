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
'@ #Command here-string
        if ($PSCmdlet.ParameterSetName -eq "None") {
            Invoke-Expression -Command $Command
        } #if ParameterSetName is None
        
        else {
            $InvokeCommandArgs = @{}
            $InvokeCommandArgs.ScriptBlock = [scriptblock]::Create($Command)

            if ($PSCmdlet.ParameterSetName -eq 'CN') {
                $InvokeCommandArgs.ComputerName = $ComputerName

                If ($Credential) {
                    $InvokeCommandArgs.Credential = $Credential
                } #if Credential is supplied

            } #if ParameterSetName is CN

            if ($PSCmdlet.ParameterSetName -eq 'Session') {
                $InvokeCommandArgs.Session = $Session
            } #if ParameterSetName is Session

            Invoke-Command @InvokeCommandArgs

        } #if ParameterSetName is NOT None    

    } #Process Script Block for Get-ProcessMemory Function 

} #Get-ProcessMemory Function Definition