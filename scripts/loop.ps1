param(
  [int] $Iterations = 30,
  [string] $Flags = '',
  [string] $Semaphore = 'True',
  [string] $Jobs = '$ncpus',
  [string] $Label = 'local',
  # MSYS2 ucrt64 prefix. When set, every package gets its include and lib dirs, as in mediacopy3000's CI.
  [string] $Ucrt = '',
  # WER LocalDumps folder. Dumps found there are moved to dumps/pass-N after each pass.
  [string] $DumpFolder = ''
)

$heapCorruption = '-1073740940'

@"
package repro
  flags: $Flags

semaphore: $Semaphore
jobs: $Jobs
"@ | Out-File -FilePath cabal.project.local -Encoding utf8
if ($Ucrt) {
  @"

package *
  extra-include-dirs: $Ucrt\include
  extra-lib-dirs: $Ucrt\lib
"@ | Out-File -FilePath cabal.project.local -Append -Encoding utf8
}

$crashes = 0
$otherFailures = 0
for ($i = 1; $i -le $Iterations; $i++) {
  if (Test-Path dist-newstyle) { Remove-Item -Recurse -Force dist-newstyle }
  $output = & cabal build all 2>&1 | Out-String
  $code = $LASTEXITCODE
  if ($output -match [regex]::Escape($heapCorruption)) {
    $crashes++
    Write-Host "pass ${i}: HEAP CORRUPTION"
    Write-Host ($output -split "`n" | Select-Object -Last 12 | Out-String)
  } elseif ($code -ne 0) {
    $otherFailures++
    Write-Host "pass ${i}: other failure, exit $code"
    Write-Host $output
  } else {
    Write-Host "pass ${i}: ok"
  }
  if ($DumpFolder -and (Test-Path $DumpFolder)) {
    $dumps = @(Get-ChildItem -Path $DumpFolder -Filter *.dmp)
    if ($dumps.Count -gt 0) {
      $target = "dumps/pass-$i"
      New-Item -ItemType Directory -Force -Path $target | Out-Null
      $dumps | Move-Item -Destination $target
      Write-Host "pass ${i}: $($dumps.Count) dump(s) saved in $target"
    }
  }
}

$line = "| $Label | ``$Flags`` | $Semaphore | $Jobs | $Iterations | $crashes | $otherFailures |"
Write-Host $line
if ($env:GITHUB_STEP_SUMMARY) {
  "| variant | flags | semaphore | jobs | passes | heap corruption | other failures |" | Out-File -FilePath $env:GITHUB_STEP_SUMMARY -Append -Encoding utf8
  "|---|---|---|---|---|---|---|" | Out-File -FilePath $env:GITHUB_STEP_SUMMARY -Append -Encoding utf8
  $line | Out-File -FilePath $env:GITHUB_STEP_SUMMARY -Append -Encoding utf8
}
if ($crashes -gt 0 -or $otherFailures -gt 0) { exit 1 }
