
[CmdletBinding()]
param(
[Alias("PhilosopherNumber")]
[int]$pNr
,
[int]$putdownCounter=1000
,
[bool]$shouldUseWaiter = $true
,
[bool]$mayStarve = $true
,
[string]$scriptLocation ="C:\scripts\ps"
,
[validateRange(2,1000)]
[int]$maxTicksToEat = 1000
)

. (join-path $scriptLocation "DiningPhilosophersProblemHelper.ps1")

function Think
{
    $ran = Get-Random -Minimum 100 -Maximum 1000
    Write-Host "Philosopher[$pNr] is thinking for $ran [ms]"
     Wait $ran
}

function Eat([int]$forkNr1, [int]$forkNr2 )
{
    $ran = Get-Random -Minimum ($maxTicksToEat/10) -Maximum $maxTicksToEat
    Write-Host "Philosopher[$pNr] is eatting for $ran [ms] with fork nr $forkNr1 and $forkNr2 "
    Increase-Eatting $pNr
    Wait $ran
}

function Try-TakeFork([int]$forkNr, [bool]$isAlreadyUsingIt=$false)
{
    if($isAlreadyUsingIt)
        {return $true}

    $isFree = IsFree-Fork $forkNr
    if($isFree )
    {
        Write-Verbose "Philosopher[$pNr] fork nr $forkNr is free"
        return (Use-Fork $forkNr)
    }
    else
    {
        Write-Verbose "Philosopher[$pNr] fork nr $forkNr is occupied"
    }
    return $false
}


function Try-Eat
{
    Write-Verbose "Philosopher[$pNr] is going to eat"
    
    $forkNr1 = $pNr
    $forkNr2 = $pNr-1
    $tryToEatCounter=0
    while($tryToEatCounter -lt $putdownCounter)
    {
        #region with Waiter
        if($shouldUseWaiter)
        {
            WaitForWaiter -alreadyWaiting $tryToEatCounter
        }
        #endregion

        [bool]$inUseforkNr1 =  Try-TakeFork $forkNr1 $inUseforkNr1
        if($inUseforkNr1)
        {

            [bool]$inUseforkNr2 =  Try-TakeFork $forkNr2 $inUseforkNr2
            if($inUseforkNr2)
            {
                if($shouldUseWaiter)
                {
                    Write-Host "Philosophe [$pNr] is saying takink you to waiter"
                    ThankToWaiterForFork $pNr
                }
                Eat $forkNr1 $forkNr2
                $inUseforkNr1 = Drop-Fork $forkNr1
                $inUseforkNr2 = Drop-Fork $forkNr2
                return
            }
        }
        $tryToEatCounter++               
    }

    if($inUseforkNr1)
    {Drop-Fork $forkNr1}

    if($inUseforkNr2)
    {Drop-Fork $forkNr2}
    
    if($mayStarve)
    {
        throw "Philosopher[$pNr] died because of hunger"
    }
}

function Use-Fork([int]$forkNr)
{
    [int[]]$usedForks = Get-UsedForks
    $usedForks[$forkNr]--
    Set-UsedForks $usedForks
    Write-Host "Philosopher[$pNr] takes fork nr $forkNr"
    return $true
}

function Drop-Fork([int]$forkNr)
{
    [int[]]$usedForks = Get-UsedForks
    if( $usedForks -lt 1)
    {
        $usedForks[$forkNr]++
        Set-UsedForks $usedForks
    }
    return ($usedForks[$forkNr] -eq 0) #is using fork if usedForks is = 0
}

function IsFree-Fork([int]$forkNr)
{
    return (Get-UsedForks)[$forkNr] -gt 0
}

#region with Waiter
function WaitForWaiter([int]$alreadyWaiting)
{
    Rise-Requeste $pNr
    Write-Host "Philosopher[$pNr] had rise a request and now is waiting for waiter. He is already waiting $alreadyWaiting ticks"

    [int]$tryToEatCounter = $alreadyWaiting
    while($tryToEatCounter -lt  $putdownCounter)
    {
        $allowance = Get-AllowanceFromWaiter $pNr 
        if($allowance)
        {
            Write-Host "Philosopher[$pNr] had allowance"
            return
        }
        Wait $maxTicksToEat
            
        $tryToEatCounter++    
    }
    
    if($mayStarve)
    {
        Write-Host "Philosopher[$pNr] is waiting for waiter: $tryToEatCounter ticks"
        throw "Philosopher[$pNr] died because of hunger while waiting for waiter"
    }
}
#endregion 


[bool]$inUseforkNr1 =$false
[bool]$inUseforkNr2 =$false

$count = 0
while($count -lt 100000)
{
    Think
    Try-Eat
    $count++
}
