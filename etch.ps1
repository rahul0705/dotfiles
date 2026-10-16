$ErrorActionPreference = 'Stop'

# Follow the user-local launcher link back to its checkout, including relative targets.
$launcher = Get-Item -LiteralPath $PSCommandPath -Force
$linkCount = 0
while ($launcher.LinkType -eq 'SymbolicLink') {
    $linkCount++
    if ($linkCount -gt 40) {
        throw 'Etch launcher: symlink cycle or chain exceeds 40 links.'
    }
    $target = @($launcher.Target)[0]
    if (![IO.Path]::IsPathRooted($target)) {
        $target = Join-Path $launcher.DirectoryName $target
    }
    $launcher = Get-Item -LiteralPath $target -Force
}

$root = $launcher.DirectoryName
$engine = Join-Path $root 'vendor\etch\etch'
if (!(Test-Path -LiteralPath $engine -PathType Leaf)) {
    throw 'Initialize Etch first: git submodule update --init vendor/etch'
}
$etchArguments = $args
if ($etchArguments.Count -eq 0) {
    $etchArguments = @('plan', '--profile', 'developer')
}

Push-Location -LiteralPath $root
try {
    & python -S $engine @etchArguments
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $exitCode
