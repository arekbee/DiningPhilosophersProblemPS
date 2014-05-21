
#region main func
function Get-ArrVariable([string]$name)
{
    $varString = [Environment]::GetEnvironmentVariable($name, [System.EnvironmentVariableTarget]::User)
    if([string]::IsNullOrEmpty($varString))
    {
        return @() 
    }

    [int[]]$var = $varString.Split(';')
    return $var
}

function Set-ArrVariable([string]$name, [array]$arr)
{
    Set-ArrVariableStr $name ($arr  -join ';')
}
function Set-ArrVariableStr([string]$name, [string]$str)
{
    [Environment]::SetEnvironmentVariable($name, $str, [System.EnvironmentVariableTarget]::User)
}

function Clean-ArrVariable([string[]]$names)
{
    $names | %{ Set-ArrVariableStr $_  "" }
}
#endregion


function Wait([int]$sleepTime=1)
{
    [System.Threading.Thread]::Sleep($sleepTime)
}

function Set-UsedForks([int[]]$usedForksArr)
{
    Set-ArrVariable "usedForks"  $usedForksArr
}

function Get-UsedForks
{
    return Get-ArrVariable  "usedForks"
}

#region info
function Increase-Eatting([int]$philosopherNr)
{
    Write-Host "Increase-Eatting for $philosopherNr"
    $meals = Get-Meals 
    $meals[$philosopherNr]++
    Set-Meals $meals
}

function Set-Meals([int[]]$mealsArr)
{
    Set-ArrVariable "meals" $mealsArr
}

function Get-Meals
{
    return Get-ArrVariable "meals"
}
#endregion


#region WITH WAITER
function TakeOrders
{
    [array]$forks = Get-UsedForks 
    Initialize-ArrVariable "request" $forks.Count
    Initialize-ArrVariable "response" $forks.Count
}



function Rise-Requeste([int]$philosopherNr)
{
  $requests =  Get-ArrVariable "request"
  if($requests -and $requests.Count -gt $philosopherNr )
  {
      if($requests[$philosopherNr] -eq 0)
      {
        $requests[$philosopherNr]++
        Set-ArrVariable "request" $requests
      }
  }
}

function Get-AllowanceFromWaiter([int]$philosopherNr)
{
  $res =  Get-ArrVariable "response"
  if($res -and $res.Count -gt $philosopherNr )
  {
    return ($res[$philosopherNr] -gt 0)
  }
  return $false
}

function Initialize-ArrVariable([string]$name, [int]$count, [switch]$force)
{
    $var = get-ArrVariable $name
    if(-not($var) -OR $force)
    {
        Set-ArrVariable -name $name -arr (@(0) * $count)
    }
}

function ThankToWaiterForFork([int]$pNr)
{
    $requests =  Get-ArrVariable "request"
    if($requests -and $requests.Count -gt $pNr )
    {
          $requests[$pNr]--
          Set-ArrVariable "request" $requests
    }
}
#endregion