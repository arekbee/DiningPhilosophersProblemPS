param(
[string]$scriptLocation ="."
,
[int]$waitingForTanksForFork = 10
,
[switch]$randomisation=$true
)

. (join-path $scriptLocation "DiningPhilosophersProblemHelper.ps1")

function Get-Request
{
    return (Get-ArrVariable "request")
}

function Get-IndexOfMaxValue
{
    param([int[]]$arr)

    $max  = [int]::MinValue
    $maxIndex = -1
    $arr | % ($i= 0) {
        if($_ -gt $max)
        {
            $maxIndex = $i 
        }
    }
    return $maxIndex
}

function Give-Allowance([int]$pNr)
{
  $response=Get-ArrVariable "response"
  $response[$pNr]++
  Set-ArrVariable "response" $response
}

function Served-Philosopher([int]$pNr)
{
  $response=Get-ArrVariable "response"
  if($response[$pNr] -gt 0)
  {
    $response[$pNr]--
    Set-ArrVariable "response" $response 
  }
}

Write-host "Randomisation is set to  $randomisation"

$count=0
while($count -lt 1000000)
{
   $request =  Get-Request
   $forks = Get-UsedForks
   
   $startfrom =0
   #region randomisation

   if( $randomisation -and ($count % 2 -eq 0))
   {
        $startfrom = 1
        Write-Host "Waiter: Starting asking from random number: $startfrom"
   } 
   #endregion

   for ($i=$startfrom; $i -lt $request.Count; $i++ )
   {
    if( ((Get-Request)[$i]) -gt 0) #had requested
    {
        $iPrev = $i -1
        if( (Get-UsedForks)[$i] -gt 0 -and (Get-UsedForks)[$iPrev] -gt 0) #Avaliable forks
        {
            Write-Host "Waiter: Allowing to take forks nr $i nad $iPrev to philosopher nr $i"
            Give-Allowance $i
            
            $counterForTanksFroFork=0
            while( ((Get-Request)[$i]) -ne 0 -and $counterForTanksFroFork -lt $waitingForTanksForFork)
            {
                $counterForTanksFroFork++
                Wait
            }
           Served-Philosopher $i
        }
    }
   } 
   $count++
}

