##########################
function add-agent {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$username,
    [Parameter(Mandatory = $true)]
    [string]$newhost,
    [Parameter(Mandatory = $true)]
    [string]$pw
  )
  process {
    $ts = get-date -f "MMddyyyyhhmm"
    copy-item .\vc-agent-007 -Destination .\vc-agent-007-$ts
    $c = Get-Content -Path .\vc-agent-007| ConvertFrom-Json -AsHashtable
    $agentcount = $c.'drv-manual-host-uri'| Measure-Object | Select-Object -ExpandProperty Count
    $creds = $username + "@" + $pw
    $pg = "$newhost"+":"+"$creds"+":5432/postgres?sslenabled=true&sslmode=require"
    if($agentcount -eq 1){
      $outconfig = @{
          "drv-manual-query-capture"  = "poll"
          "drv-manual-host-uri"       = $c.'drv-manual-host-uri', $pg
      }
      $outconfig | ConvertTo-Json -depth 100 | out-file .\vc-agent-007 -Force
    }
    if($agentcount -ge 2){
      @($c['drv-manual-host-uri'] += $pg)
        $outconfig = @{
          "drv-manual-query-capture"  = "poll"
          "drv-manual-host-uri"       = $c.'drv-manual-host-uri'
        }
        $outconfig | ConvertTo-Json -depth 100 | out-file .\vc-agent-007 -Force
    }
  }
}
# add-agent
##########################
function remove-agent {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$hostname
  )
  process {
    $c = Get-Content -Path .\vc-agent-007| ConvertFrom-Json -AsHashtable
    $uri = $c.PSObject.Properties.Value.'drv-manual-host-uri'
    $remove = $uri| Where-Object{$_ -notmatch "$hostname"}
    @($c['drv-manual-host-uri'] = $remove)
    $outconfig = @{
      "drv-manual-query-capture"  = "poll"
      "drv-manual-host-uri"       = $c.'drv-manual-host-uri'
    }
    $outconfig | ConvertTo-Json -depth 100 | out-file .\vc-agent-007 -Force  
  }
}  
# remove-agent
##########################
function get-agent {
  $c = Get-Content -Path .\vc-agent-007| ConvertFrom-Json -AsHashtable
  $uri = $c.PSObject.Properties.Value.'drv-manual-host-uri'
  if($uri.Count -eq 1){
    write-host "$($uri.Count) configuration in this file " -BackgroundColor Black -ForegroundColor Yellow
    foreach($u in $uri){
      write-host $u -BackgroundColor Black -ForegroundColor Yellow
    }
  }
  if($uri.Count -gt 1){
    write-host "There are $($uri.Count) configurations in this file " -BackgroundColor Black -ForegroundColor Yellow
    foreach($u in $uri){
      write-host $u -BackgroundColor Black -ForegroundColor Yellow
    }
  }
}
# get-agent
##########################

# foreach ($profileLocation in ($PROFILE | Get-Member -MemberType NoteProperty).Name)
# {
#     Write-Host "$($profileLocation): $($PROFILE.$profileLocation)"
# }
