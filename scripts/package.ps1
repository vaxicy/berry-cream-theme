param([string]$OutputDirectory, [switch]$Force)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $OutputDirectory) { $OutputDirectory = Split-Path -Parent (Split-Path -Parent $projectRoot) }
$manifest = Get-Content -LiteralPath (Join-Path $projectRoot 'manifest.json') -Raw | ConvertFrom-Json
$zipPath = Join-Path $OutputDirectory "berry-cream-theme-$($manifest.version).zip"
if ((Test-Path -LiteralPath $zipPath) -and -not $Force) { throw "Archive already exists: $zipPath" }
$items = @('manifest.json','logo','README.md','scripts','store-assets','LICENSE','.gitignore') | ForEach-Object { Join-Path $projectRoot $_ }
Compress-Archive -LiteralPath $items -DestinationPath $zipPath -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
  $names = @($zip.Entries | ForEach-Object { $_.FullName -replace '\\', '/' })
  if ($names -notcontains 'manifest.json') { throw 'Manifest must sit at the ZIP root' }
  if ($names | Where-Object { $_ -match '(^|/)(\.git|\.codebuddy|__pycache__)/|\.(pak|zip|pyc)$' }) { throw 'Unwanted files in archive' }
  foreach ($ref in $manifest.icons.PSObject.Properties.Value) {
    if ($names -notcontains $ref) { throw "Missing manifest reference: $ref" }
  }
} finally { $zip.Dispose() }
Get-Item -LiteralPath $zipPath | Select-Object FullName,Length
$uploadPath = Join-Path $OutputDirectory "berry-cream-theme-$($manifest.version)-upload.zip"
if ((Test-Path -LiteralPath $uploadPath) -and -not $Force) { throw "Archive already exists: $uploadPath" }
$uploadItems = @('manifest.json','logo') | ForEach-Object { Join-Path $projectRoot $_ }
Compress-Archive -LiteralPath $uploadItems -DestinationPath $uploadPath -Force
$upload = [System.IO.Compression.ZipFile]::OpenRead($uploadPath)
try {
  $entries = @($upload.Entries | ForEach-Object { $_.FullName -replace '\\', '/' })
  if ($entries -notcontains 'manifest.json' -or $entries -notcontains 'logo/logo128.png') { throw 'Upload package missing required files' }
} finally { $upload.Dispose() }
Get-Item -LiteralPath $uploadPath | Select-Object FullName,Length
