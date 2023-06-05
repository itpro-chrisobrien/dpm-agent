##########################
function add-agent {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$dbalias,
    [Parameter(Mandatory = $true)]
    [string]$pghost,
    [Parameter(Mandatory = $true)]
    [string]$pgpw,
    [Parameter(Mandatory = $true)]
    [string]$pgip
  )
  process {

    [int]$incre = gci | Where-Object {$_.Name -like "vc-agent-007-backup*"}|measure|select -ExpandProperty Count
    function comparethis([ref]$incre) {
        $incre.value++;
    }
    comparethis([ref]$incre)
    copy-item .\vc-agent-007.conf -Destination ".\vc-agent-007-backup-${incre}.conf"

    $c = Get-Content -Path .\vc-agent-007.conf| ConvertFrom-Json -AsHashtable
    $agentcount = $c.'drv-manual-host-uri'| Measure-Object | Select-Object -ExpandProperty Count
    $pg = "$dbalias=postgres://vividcortex%40${pghost}:${pgpw}@${pgip}:5432/postgres?sslenabled=true&sslmode=require"

    if($agentcount -eq 0){
      $outconfig = @{
          "drv-manual-query-capture"  = "poll"
          "drv-manual-host-uri"       = $pg
      }
      $outconfig | ConvertTo-Json -depth 100 | out-file .\vc-agent-007.conf -Force
    }
    if($agentcount -ge 1){
      @($c['drv-manual-host-uri'] += ",$pg")
        $outconfig = @{
          "drv-manual-query-capture"  = "poll"
          "drv-manual-host-uri"       = $c.'drv-manual-host-uri'
        }
        $outconfig | ConvertTo-Json -depth 100 | out-file .\vc-agent-007.conf -Force
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
    $c = Get-Content -Path .\vc-agent-007.conf| ConvertFrom-Json -AsHashtable
    $uri = $c.PSObject.Properties.Value.'drv-manual-host-uri'
    $remove = $uri| Where-Object{$_ -notmatch "$hostname"}
    @($c['drv-manual-host-uri'] = $remove)
    $outconfig = @{
      "drv-manual-query-capture"  = "poll"
      "drv-manual-host-uri"       = $c.'drv-manual-host-uri'
    }
    $outconfig | ConvertTo-Json -depth 100 | out-file .\vc-agent-007.conf -Force  
  }
}  
# remove-agent
##########################
function get-agent {
  $c = Get-Content -Path .\vc-agent-007.conf| ConvertFrom-Json -AsHashtable
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
  if($uri.Count -eq 0){
    write-host "This host is not yet configured" -BackgroundColor Black -ForegroundColor Yellow
    foreach($u in $uri){
      write-host $u -BackgroundColor Black -ForegroundColor Yellow
    }
  }
}

function restore-agent {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$old
  )
  process {
    Remove-Item .\vc-agent-007.conf
    $items = gci | Where-Object {$_.Name -like "vc-agent-007-backup*"}|Select-Object -Property Name, CreationTime | sort DateTime -Descending
    write-host $items
    $old = Read-Host "Choose the backup number 1, 2, 3, etc"
    Rename-Item -Path "vc-agent-007-backup-$old.conf" -NewName 'vc-agent-007.conf'
  }
}
# restore-agent
##########################

# foreach ($profileLocation in ($PROFILE | Get-Member -MemberType NoteProperty).Name)
# {
#     Write-Host "$($profileLocation): $($PROFILE.$profileLocation)"
# }
