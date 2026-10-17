# Fresh-machine bootstrap; existing checkouts are deliberately never updated.
$ErrorActionPreference = 'Stop'
# Handle native exit codes explicitly, even when the caller enables PS7 native errors.
$PSNativeCommandUseErrorActionPreference = $false
$repository = 'https://github.com/rahul0705/dotfiles.git'
$destination = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $HOME '.dotfiles' }
$module = 'etch'
$noModule = $false

function Fail([int]$code, [string]$message) {
    [Console]::Error.WriteLine("Dotfiles installer: $message")
    exit $code
}

for ($i = 0; $i -lt $args.Count; $i++) {
    switch ($args[$i]) {
        '--module' {
            $i++
            if ($i -ge $args.Count -or $args[$i] -notmatch '^[a-zA-Z0-9_][a-zA-Z0-9_-]*$') {
                Fail 2 '--module requires a valid name.'
            }
            $module = $args[$i]
        }
        '--no-module' { $noModule = $true }
        { $_ -in '--help', '-h' } {
            Write-Output 'Usage: install.ps1 [--module NAME] [--no-module]'
            Write-Output 'Clone to DOTFILES_DIR (default: ~/.dotfiles), then apply only etch.'
            Write-Output '--no-module always takes precedence. Existing checkouts are untouched.'
            exit 0
        }
        default { Fail 2 "Unknown argument: $($args[$i])" }
    }
}
if ($noModule) { $module = $null }
if (!(Get-Command git -ErrorAction SilentlyContinue)) { Fail 127 'Git is required; install it and retry.' }

if (Test-Path -LiteralPath $destination) {
    if (Test-Path -LiteralPath (Join-Path $destination '.git')) {
        $origin = & git -C $destination remote get-url origin 2>$null
        if ($LASTEXITCODE -eq 0 -and $origin -cmatch '^(https://github\.com/|git@github\.com:)rahul0705/dotfiles(\.git)?$') {
            & git -C $destination rev-parse --is-inside-work-tree 2>$null | Out-Null
            if ($LASTEXITCODE -ne 0) { Fail 1 "Invalid checkout at $destination; it was not changed." }
            Write-Output "Dotfiles already exist at $destination; nothing changed."
            exit 0
        }
    }
    Fail 1 "Destination is occupied by an unrelated file or directory: $destination"
}

if ($module) {
    if (!(Get-Command python -ErrorAction SilentlyContinue)) {
        Fail 127 'Python 3.9+ is required to run Etch; install it or use --no-module.'
    }
    & python -S -c 'import sys; sys.exit(sys.version_info < (3, 9))'
    if ($LASTEXITCODE -ne 0) { Fail $LASTEXITCODE 'Python 3.9+ is required to run Etch.' }
}

& git clone -- $repository $destination
if ($LASTEXITCODE -ne 0) {
    Fail $LASTEXITCODE "Clone failed. Any partial destination was retained at $destination; inspect it before retrying."
}
& git -C $destination submodule update --init --recursive
if ($LASTEXITCODE -ne 0) {
    Fail $LASTEXITCODE "Submodule initialization failed at $destination. Repair it manually; reruns do not update existing checkouts."
}
if ($module) {
    $engine = Join-Path $destination 'vendor/etch/etch'
    & python -S $engine apply $module --repo $destination
    if ($LASTEXITCODE -ne 0) {
        Fail $LASTEXITCODE "Etch module $module failed. Checkout retained at $destination; rerun Etch directly after resolving the error."
    }
}
Write-Output "Dotfiles installed at $destination."
