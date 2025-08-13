# ====== CONFIG ======
$Base   = "%BOOKSTACKADDRESS:PORT%"   # no trailing slash
$ID     = "%TOKENID%"
$Secret = "%TOKENSECRET%"

$Base = $Base.TrimEnd('/')
$Headers = @{
  Authorization = "Token $ID`:$Secret"
  Accept        = "application/json"
}

# ====== INITIAL SHELF/BOOK/CHAPTER SETUP ======
# Follow the example below to add more books and chapters to each shelf
# This is set up coded to the "Infrastructure" shelf, I need to add 
# other shelves 
# ====== HELPERS ======
function New-BSItem {
  param($Method, $Path, $BodyObj)
  $params = @{
    Method  = $Method
    Uri     = "$Base/api/$Path"
    Headers = $Headers
  }
  if ($PSBoundParameters.ContainsKey('BodyObj') -and $null -ne $BodyObj) {
    $params.ContentType = 'application/json; charset=utf-8'
    $params.Body        = ($BodyObj | ConvertTo-Json -Depth 6)
  }
  Invoke-RestMethod @params
}

function Get-All {
  param($Path)
  $r = Invoke-RestMethod -Uri "$Base/api/$Path" -Headers $Headers -Method GET
  if ($null -ne $r.data) { return $r.data } else { return $r }
}

function Ensure-Book {
  param($Name,$Desc)
  $existing = (Get-All "books") | Where-Object { $_.name -eq $Name } | Select-Object -First 1
  if ($existing) { return $existing }
  New-BSItem POST "books" @{ name = $Name; description = $Desc }
}

function Ensure-Chapter {
  param($BookId,$Name,$Desc)
  try {
    $contents = New-BSItem GET "books/$BookId/contents" $null
    $hit = $contents | Where-Object { $_.type -eq 'chapter' -and $_.name -eq $Name } | Select-Object -First 1
    if ($hit) { return $hit }
  } catch { } # some versions lack /contents; that's fine
  New-BSItem POST "chapters" @{ book_id = $BookId; name = $Name; description = $Desc }
}

# ====== 1) Find your existing Infrastructure shelf ======
$shelf = (Get-All "shelves") | Where-Object { $_.name -match 'Infrastructure' } | Select-Object -First 1
if (-not $shelf) { throw "Infrastructure shelf not found. (Create/rename it in the UI and retry.)" }

# ====== 2) Ensure the four books ======
$bookAD  = Ensure-Book "Active Directory"    "AD architecture, DC lifecycle, GPO/auth, and operations."
$bookHV  = Ensure-Book "Hyper-V"             "Virtualization standards, host fabric, VM lifecycle & ops."
$bookNET = Ensure-Book "Network & Security"  "Firewall, switching, wireless, remote access, and diagrams."
$bookEP  = Ensure-Book "Endpoints"           "Windows client baselines, models, provisioning, software."

# ====== 3) Attach books to shelf ======
try {
  New-BSItem PUT "shelves/$($shelf.id)" @{
    name        = $shelf.name
    description = $shelf.description
    books       = @($bookAD.id, $bookHV.id, $bookNET.id, $bookEP.id)
  } | Out-Null
} catch {
  New-BSItem PUT "shelves/$($shelf.id)" @{
    name        = $shelf.name
    description = $shelf.description
    books       = @(@{id=$bookAD.id}, @{id=$bookHV.id}, @{id=$bookNET.id}, @{id=$bookEP.id})
  } | Out-Null
}

# ====== 4) Chapters ======
# AD
Ensure-Chapter $bookAD.id  "Architecture"         "Design, FSMO, namespace, sites & replication."   | Out-Null
Ensure-Chapter $bookAD.id  "Domain Controllers"   "Inventory, build standards, lifecycle, health."  | Out-Null
Ensure-Chapter $bookAD.id  "GPO & Authentication" "Strategy, baselines, password/lockout, Kerberos."| Out-Null
Ensure-Chapter $bookAD.id  "Operations"           "Health checks, backup/restore, common tasks."    | Out-Null
# Hyper-V
Ensure-Chapter $bookHV.id  "Hosts & Fabric"       "Host inventory, firmware/driver, storage/network." | Out-Null
Ensure-Chapter $bookHV.id  "Virtual Machines"     "VM inventory, criticality/backup, build patterns." | Out-Null
Ensure-Chapter $bookHV.id  "Operations"           "Live/storage migration, backup/restore, capacity."  | Out-Null
# Network & Security
Ensure-Chapter $bookNET.id "Firewall"             "Config, rule standards, change, backups, firmware." | Out-Null
Ensure-Chapter $bookNET.id "Switching"            "Models, VLAN schema, trunk/access, backups."        | Out-Null
Ensure-Chapter $bookNET.id "Wireless"             "AP inventory, SSIDs, security posture, controllers."| Out-Null
Ensure-Chapter $bookNET.id "Remote Access"        "LogMeIn policy; RRAS retired notes/rollback."       | Out-Null
Ensure-Chapter $bookNET.id "Diagrams"             "Physical & logical topology with source files."     | Out-Null
# Endpoints
Ensure-Chapter $bookEP.id  "Windows Baseline (10/11)"    "SOE image, hardening, update rings, support."  | Out-Null
Ensure-Chapter $bookEP.id  "Hardware Models & Drivers"   "Approved models, BIOS/driver baselines."        | Out-Null
Ensure-Chapter $bookEP.id  "Join/Provisioning Checklist" "Join, naming, enrollment, hand-off steps."      | Out-Null
Ensure-Chapter $bookEP.id  "Software Catalog"            "Standard apps by role, license notes."          | Out-Null

"Done. Shelf=$($shelf.id) Books: AD=$($bookAD.id) HV=$($bookHV.id) NET=$($bookNET.id) EP=$($bookEP.id)"
