#Dining philosophers problem

function Clean
{
    cls
    get-job | Stop-Job
    get-job | Remove-Job

    Clean-ArrVariable "request", "response","usedForks","meals"
}

function Run-DPP
{
    param
    (
		[int]
		[validaterange(2,100)]
		$philosopherNumber =10
		,
		[switch]$useWaiter=$true
		#,
		#[switch]$useHierarchy
		#,
		#[switch]$useChandyMisraSolution  
		,
		[string]
		$scriptLocation = $PSScriptRoot
		,
		[switch]$showAll
    )

    . (join-path $scriptLocation "DiningPhilosophersProblemHelper.ps1")
    Clean #after DiningPhilosophersProblemHelper script

    $scriptPath = join-path $scriptLocation "Run-Philosopher.ps1"

    #region setting globals
    Set-UsedForks (@(1) * $philosopherNumber)
    Set-Meals (@(0) * $philosopherNumber)
    if($useWaiter)
		{TakeOrders}
    #endregion

    if($useWaiter)
    {
        $waiterScriptPath = join-path $scriptLocation "Run-Waiter.ps1"
        Start-job -FilePath $waiterScriptPath -Name 'Waiter'
    }

   for( $i=0; $i -lt $philosopherNumber ; $i++)
   {
        Start-job -FilePath $scriptPath  -ArgumentList  $i -Verbose -Name "Philo_$i"
   } 

    $counter = 0
    while($counter -lt 1000000)
    {
        if($showAll)
		{
			get-job | receive-job 
        }
		get-job -Name Waiter | receive-job 
        get-job -State Failed | Remove-Job
        if($counter % 10 -eq 0)
        {
            Write-Host "Status:  $(Get-UsedForks)"
            Write-Host "Meals:   $(Get-Meals)"
        }
         Wait 100

        $counter++
    }
}

Run-DPP -showAll