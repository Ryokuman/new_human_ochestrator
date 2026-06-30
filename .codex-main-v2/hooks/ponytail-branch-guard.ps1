$ErrorActionPreference = "SilentlyContinue"

$repoRoot = git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
  Write-Error "Ponytail branch guard must run inside a git repository."
  exit 1
}

Set-Location $repoRoot

$currentBranch = git branch --show-current 2>$null
$legacyMainV2ForkPoint = "b1516c8c3e5b94cd8b413debeedee2ed8e061445"
$remoteName = $null
if ($currentBranch -eq "main" -or $currentBranch -eq "develop") {
  Write-Error "Ponytail is only enabled on main-v2 or branches derived from main-v2."
  exit 1
}

function Test-ShallowRepository {
  $isShallow = git rev-parse --is-shallow-repository 2>$null
  return $isShallow -eq "true"
}

function Select-Remote {
  $branchRemote = git config --get "branch.$currentBranch.remote" 2>$null

  if (-not [string]::IsNullOrWhiteSpace($branchRemote)) {
    git remote get-url $branchRemote *> $null
    if ($LASTEXITCODE -eq 0) {
      $script:remoteName = $branchRemote
      return $true
    }
  }

  git remote get-url origin *> $null
  if ($LASTEXITCODE -eq 0) {
    $script:remoteName = "origin"
    return $true
  }

  $firstRemote = git remote 2>$null | Select-Object -First 1
  if (-not [string]::IsNullOrWhiteSpace($firstRemote)) {
    $script:remoteName = $firstRemote
    return $true
  }

  return $false
}

function Get-RemoteRef {
  param([string]$Branch)

  return "refs/remotes/$remoteName/$Branch"
}

function Ensure-HeadHistory {
  if (-not (Test-ShallowRepository)) {
    return
  }

  if ([string]::IsNullOrWhiteSpace($remoteName)) {
    return
  }

  git fetch --quiet --deepen=100000 --no-tags $remoteName *> $null
  if ($LASTEXITCODE -ne 0) {
    git fetch --quiet --unshallow --no-tags $remoteName *> $null
  }
}

function Ensure-MainV2Ref {
  if ([string]::IsNullOrWhiteSpace($remoteName)) {
    return
  }

  $mainV2Ref = Get-RemoteRef "main-v2"
  if (Test-ShallowRepository) {
    git fetch --quiet --deepen=100000 --no-tags $remoteName "main-v2:$mainV2Ref" *> $null
    if ($LASTEXITCODE -ne 0) {
      git fetch --quiet --unshallow --no-tags $remoteName "main-v2:$mainV2Ref" *> $null
    }
  } else {
    git fetch --quiet --no-tags $remoteName "main-v2:$mainV2Ref" *> $null
  }
}

function Ensure-MainRef {
  if ([string]::IsNullOrWhiteSpace($remoteName)) {
    return
  }

  $mainRef = Get-RemoteRef "main"
  if (Test-ShallowRepository) {
    git fetch --quiet --deepen=100000 --no-tags $remoteName "main:$mainRef" *> $null
    if ($LASTEXITCODE -ne 0) {
      git fetch --quiet --unshallow --no-tags $remoteName "main:$mainRef" *> $null
    }
  } else {
    git fetch --quiet --no-tags $remoteName "main:$mainRef" *> $null
  }
}

function Test-HasMainRef {
  git rev-parse --verify main *> $null
  if ($LASTEXITCODE -eq 0) {
    return $true
  }

  if ([string]::IsNullOrWhiteSpace($remoteName)) {
    return $false
  }

  git rev-parse --verify (Get-RemoteRef "main") *> $null
  return $LASTEXITCODE -eq 0
}

function Test-InMainLineage {
  param([string]$Commit)

  if (-not [string]::IsNullOrWhiteSpace($remoteName)) {
    $mainRef = Get-RemoteRef "main"
    git rev-parse --verify $mainRef *> $null
    if ($LASTEXITCODE -eq 0) {
      git merge-base --is-ancestor $Commit $mainRef *> $null
      return $LASTEXITCODE -eq 0
    }
  }

  git rev-parse --verify main *> $null
  if ($LASTEXITCODE -eq 0) {
    git merge-base --is-ancestor $Commit main *> $null
    if ($LASTEXITCODE -eq 0) {
      return $true
    }
  }

  return $false
}

function Test-FirstParentHasMainV2OnlyCommit {
  param([string]$MainV2Ref)

  $firstParentCommits = git rev-list --first-parent HEAD 2>$null
  foreach ($commit in $firstParentCommits) {
    git merge-base --is-ancestor $commit $MainV2Ref *> $null
    if (($LASTEXITCODE -eq 0) -and (-not (Test-InMainLineage $commit))) {
      return $true
    }
  }

  return $false
}

function Test-MainV2Lineage {
  param(
    [string]$MainV2Ref
  )

  git rev-parse --verify $MainV2Ref *> $null
  if ($LASTEXITCODE -ne 0) {
    return $false
  }

  git merge-base --is-ancestor $MainV2Ref HEAD *> $null
  if ($LASTEXITCODE -eq 0) {
    if ((Test-HasMainRef) -and (Test-InMainLineage $MainV2Ref)) {
      return $false
    }
    if (-not (Test-FirstParentHasMainV2OnlyCommit $MainV2Ref)) {
      return $false
    }
    return $true
  }

  $sharedBase = git merge-base $MainV2Ref HEAD 2>$null

  return (-not [string]::IsNullOrWhiteSpace($sharedBase)) -and
    ($sharedBase -ne $legacyMainV2ForkPoint) -and
    (Test-HasMainRef) -and
    (Test-FirstParentHasMainV2OnlyCommit $MainV2Ref) -and
    (-not (Test-InMainLineage $sharedBase))
}

Select-Remote *> $null
Ensure-HeadHistory
Ensure-MainV2Ref
Ensure-MainRef

if ($currentBranch -eq "main-v2" -and -not [string]::IsNullOrWhiteSpace($remoteName)) {
  $mainV2Ref = Get-RemoteRef "main-v2"
  git rev-parse --verify $mainV2Ref *> $null
  if ($LASTEXITCODE -eq 0) {
    git merge-base --is-ancestor $mainV2Ref HEAD *> $null
    if ($LASTEXITCODE -ne 0) {
      Write-Error "Ponytail is only enabled on the verified main-v2 branch or branches derived from main-v2."
      exit 1
    }
  }
}

if (-not [string]::IsNullOrWhiteSpace($remoteName)) {
  $mainV2Ref = Get-RemoteRef "main-v2"
  git rev-parse --verify $mainV2Ref *> $null
  if ($LASTEXITCODE -eq 0) {
    if (Test-MainV2Lineage $mainV2Ref) {
      exit 0
    }
  } elseif (Test-MainV2Lineage "main-v2") {
    exit 0
  }
} elseif (Test-MainV2Lineage "main-v2") {
  exit 0
}

Write-Error "Ponytail is only enabled on main-v2 or branches derived from main-v2."
exit 1
