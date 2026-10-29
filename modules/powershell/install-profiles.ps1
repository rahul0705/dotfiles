param(
    [string]$DocumentsDirectory = [Environment]::GetFolderPath('MyDocuments', 'DoNotVerify')
)
$ErrorActionPreference = 'Stop'
if (-not $DocumentsDirectory) { throw 'Cannot locate the current user Documents directory.' }

# Resolve redirected Documents even before the folder exists on a fresh account.
$loader = '. (Join-Path $env:USERPROFILE ''.config\powershell\profile.ps1'')'
foreach ($shellDirectory in @('WindowsPowerShell', 'PowerShell')) {
    $directory = Join-Path $DocumentsDirectory $shellDirectory
    $profilePath = Join-Path $directory 'profile.ps1'
    $content = ''
    $encoding = New-Object System.Text.UTF8Encoding($true)
    if (Test-Path -LiteralPath $profilePath) {
        # Preserve BOM-detected encodings, including Windows PowerShell UTF-16 files.
        $reader = New-Object System.IO.StreamReader($profilePath, $true)
        try {
            $content = $reader.ReadToEnd()
            $encoding = $reader.CurrentEncoding
        } finally { $reader.Dispose() }
    }
    if (($content -split '\r?\n') -notcontains $loader) {
        New-Item -ItemType Directory -Force $directory | Out-Null
        $separator = if ($content -and -not $content.EndsWith("`n")) { "`r`n" } else { '' }
        [IO.File]::AppendAllText($profilePath, "$separator$loader`r`n", $encoding)
    }
}

# One-time profile integration; the linked initialization file keeps receiving updates.
$state = Join-Path $env:USERPROFILE '.local\state\powershell'
New-Item -ItemType Directory -Force $state | Out-Null
New-Item -ItemType File -Force (Join-Path $state 'profiles-installed') | Out-Null
