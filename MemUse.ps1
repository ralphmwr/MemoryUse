$TotalInUse = ((Get-Process).WorkingSet | Measure-Object -Sum).sum
Get-Process |
    Group-Object Name |
        Select-Object Name,
                      Count, 
                      @{n="WorkingSet";e={(Measure-Object -InputObject $_.Group.WorkingSet -Sum).sum}},
                      @{n="Percentage";e={(Measure-Object -InputObject $_.Group.WorkingSet -Sum).sum / $TotalInUse}}
