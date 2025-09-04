param(
[Parameter(Mandatory=$true)]
[string]$PageUrl,


[string]$OutDir = "$PWD\pdfs",


# Optional: restrict to the same host as the page (safer)
[switch]$SameHostOnly
)


# Create output folder
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null


# Fetch page (set a friendly UA; some sites block blank/default)
$headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" }
try {
$resp = Invoke-WebRequest -Uri $PageUrl -Headers $headers -UseBasicParsing
} catch {
Write-Error "Failed to fetch $PageUrl : $($_.Exception.Message)"
exit 1
}


# Collect PDF hrefs from <a> tags if available; fallback to regex scan
$hrefs = @()


if ($resp.Links) {
# Use parsed links first
$hrefs = $resp.Links |
Where-Object { $_.href -match '\.pdf(\b|$|\?)' } |
ForEach-Object { $_.href }
}


if (-not $hrefs -or $hrefs.Count -eq 0) {
# Fallback: scrape HTML with regex
$hrefs = [regex]::Matches($resp.Content, 'href="([^"]+\.pdf[^"]*)"', 'IgnoreCase') |
ForEach-Object { $_.Groups[1].Value }
}


if (-not $hrefs -or $hrefs.Count -eq 0) {
Write-Warning "No PDF links found on page."
exit 0
}


# Resolve to absolute URLs, de-dupe, and optionally filter by same host
$pageUri = [Uri]$PageUrl
$urls = $hrefs | ForEach-Object {
try { [Uri]::new($pageUri, $_).AbsoluteUri } catch { $null }
} | Where-Object { $_ } | Select-Object -Unique


if ($SameHostOnly) {
$urls = $urls | Where-Object { ([Uri]$_).Host -eq $pageUri.Host }
}


if (-not $urls -or $urls.Count -eq 0) {
Write-Warning "No valid PDF URLs after resolving/filters."
exit 0
}


Write-Host "Found $($urls.Count) PDF(s). Downloading to '$OutDir'..."


function Get-SafeFileName {
param([string]$Url)
$u = [Uri]$Url
# Use LocalPath to drop query; keep filename
$base = [System.IO.Path]::GetFileName($u.LocalPath)
if ([string]::IsNullOrWhiteSpace($base)) { $base = "download.pdf" }


# Remove invalid filename chars just in case
$invalid = [IO.Path]::GetInvalidFileNameChars() -join ''
$safe = ($base -replace "[$invalid]", "_")


# If file exists, add a counter
$candidate = Join-Path $OutDir $safe
$name = [IO.Path]::GetFileNameWithoutExtension($candidate)
$ext = [IO.Path]::GetExtension($candidate)
$i = 1
while (Test-Path $candidate) {
$candidate = Join-Path $OutDir ("{0} ({1}){2}" -f $name, $i, $ext)
$i++
}
return $candidate
}


# Download loop with simple progress and error handling
$idx = 0
Write-Host "Done."
