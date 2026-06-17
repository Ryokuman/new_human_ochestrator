$ErrorActionPreference = "SilentlyContinue"

$repoRoot = git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
  Write-Error "Ponytail branch guard must run inside a git repository."
  exit 1
}

Set-Location $repoRoot

$currentBranch = git branch --show-current 2>$null
$legacyMainV2ForkPoint = "b1516c8c3e5b94cd8b413debeedee2ed8e061445"
if ($currentBranch -eq "main" -or $currentBranch -eq "develop") {
  Write-Error "Ponytail is only enabled on main-v2 or branches derived from main-v2."
  exit 1
}

function Test-ShallowRepository {
  $isShallow = git rev-parse --is-shallow-repository 2>$null
  return $isShallow -eq "true"
}

function Ensure-HeadHistory {
  if (-not (Test-ShallowRepository)) {
    return
  }

  git remote get-url origin *> $null
  if ($LASTEXITCODE -ne 0) {
    return
  }

  git fetch --quiet --deepen=100000 --no-tags origin *> $null
  if ($LASTEXITCODE -ne 0) {
    git fetch --quiet --unshallow --no-tags origin *> $null
  }
}

function Ensure-MainV2Ref {
  git remote get-url origin *> $null
  if ($LASTEXITCODE -ne 0) {
    return
  }

  if (Test-ShallowRepository) {
    git fetch --quiet --deepen=100000 --no-tags origin main-v2:refs/remotes/origin/main-v2 *> $null
    if ($LASTEXITCODE -ne 0) {
      git fetch --quiet --unshallow --no-tags origin main-v2:refs/remotes/origin/main-v2 *> $null
    }
  } else {
    git fetch --quiet --no-tags origin main-v2:refs/remotes/origin/main-v2 *> $null
  }
}

function Ensure-MainRef {
  git remote get-url origin *> $null
  if ($LASTEXITCODE -ne 0) {
    return
  }

  if (Test-ShallowRepository) {
    git fetch --quiet --deepen=100000 --no-tags origin main:refs/remotes/origin/main *> $null
    if ($LASTEXITCODE -ne 0) {
      git fetch --quiet --unshallow --no-tags origin main:refs/remotes/origin/main *> $null
    }
  } else {
    git fetch --quiet --no-tags origin main:refs/remotes/origin/main *> $null
  }
}

function Test-HasMainRef {
  git rev-parse --verify main *> $null
  if ($LASTEXITCODE -eq 0) {
    return $true
  }

  git rev-parse --verify refs/remotes/origin/main *> $null
  return $LASTEXITCODE -eq 0
}

function Test-InMainLineage {
  param([string]$Commit)

  git rev-parse --verify refs/remotes/origin/main *> $null
  if ($LASTEXITCODE -eq 0) {
    git merge-base --is-ancestor $Commit refs/remotes/origin/main *> $null
    return $LASTEXITCODE -eq 0
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

Ensure-HeadHistory
Ensure-MainV2Ref
Ensure-MainRef

if ($currentBranch -eq "main-v2") {
  git rev-parse --verify refs/remotes/origin/main-v2 *> $null
  if ($LASTEXITCODE -eq 0) {
    git merge-base --is-ancestor refs/remotes/origin/main-v2 HEAD *> $null
    if ($LASTEXITCODE -ne 0) {
      Write-Error "Ponytail is only enabled on the verified main-v2 branch or branches derived from main-v2."
      exit 1
    }
  }
}

git rev-parse --verify refs/remotes/origin/main-v2 *> $null
if ($LASTEXITCODE -eq 0) {
  if (Test-MainV2Lineage "refs/remotes/origin/main-v2") {
    exit 0
  }
} elseif (Test-MainV2Lineage "main-v2") {
  exit 0
}

Write-Error "Ponytail is only enabled on main-v2 or branches derived from main-v2."
exit 1
