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
