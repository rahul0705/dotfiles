# Keep initialization shared between Windows PowerShell 5.1 and PowerShell 7.
if (Get-Command starship -CommandType Application -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
}

# Machine-specific preferences stay outside version control and run last.
$localProfile = Join-Path $env:USERPROFILE '.config\powershell\profile.local.ps1'
if (Test-Path -LiteralPath $localProfile) {
    . $localProfile
}
