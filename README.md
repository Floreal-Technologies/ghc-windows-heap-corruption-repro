# GHC 9.14.1 heap corruption on Windows: minimal reproducer

## Symptom

On `windows-latest` GitHub runners, `ghc.exe` 9.14.1 stops during `cabal build`. Cabal reports:

```
Error: [Cabal-7125]
Failed to build mediacopy3000-0.1.0 (which is required by exe:mediacopy3000 from mediacopy3000-0.1.0). The build process terminated with exit code -1073740940
```

`-1073740940` is `0xC0000374`, `STATUS_HEAP_CORRUPTION`.

## Run it

On a Windows machine with GHC 9.14.1 and cabal from GHCup, run this in PowerShell:

```powershell
./scripts/loop.ps1 -Iterations 30 -Flags '+run-io +spawn'
```
