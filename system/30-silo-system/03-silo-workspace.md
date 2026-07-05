# 사일로 작업 공간

## 기본 구조

```text
task-0055/
  goal.md
  <repo-a>/
  <repo-b>/
  artifacts/
  logs/
  reports/
```

사일로 root는 task 실행 단위의 컨테이너입니다. 제품 repo는 그 사일로가 필요할 때 clone하거나 연결하는 별도 작업 대상입니다.

사일로에는 `goal.md`, 로그, 검증 결과, 임시 산출물, PR 전 상태가 남습니다. 실제 제품 소스코드는 별도 repo/worktree 또는 gitignore된 source 위치를 기준으로 다룹니다.

## clone과 branch

- 사일로 root 안에는 해당 작업에 필요한 repo만 clone합니다.
- 프로젝트 설정이나 task가 `generator`, `runtime`, `frontend`, `backend` 같은 repo set을 지정하면 그 목록을 따릅니다.
- 각 repo는 clone 직후 기준 브랜치를 확인하고, 보호 브랜치가 아닌 새 작업 브랜치를 만듭니다.
- 같은 task 사일로에 들어온 여러 repo는 같은 task id를 포함한 브랜치 이름을 쓰되, PR 필요 여부는 repo별 diff와 완료 결과로 판단합니다.
- 공용 backend처럼 메인 오케스트레이터가 세션 동안 하나만 관리하는 서비스는 기본 clone 대상에서 제외합니다.

2계층 `Project Work SSoT` 작업은 별도 독립 merge target을 갖지 않습니다. task, issue, QA, runbook, coverage, work dashboard, Run Set 변경은 해당 project의 project 계층 메인 브랜치에서 파생한 작업 브랜치로 수행합니다. 목표 모델에서는 `project-{projectName}/main`에서 파생한 `project-{projectName}/{taskname}` 작업 브랜치를 쓰고, PR target/base도 `project-{projectName}/main`로 둡니다. 현재 호환 상태에서는 `project-{projectName}`와 `project-{projectName}-{taskname}`을 사용합니다.

root `main-v3/main`에는 project work 실데이터가 없을 수 있습니다. 사일로 workspace를 준비할 때는 root `system/`에서 task 원문을 찾으려 하지 말고 project registry/config 또는 project SSoT가 가리키는 2계층 위치를 기준으로 clone, branch, `goal.md` 참조 경로를 정합니다.

## source workspace 기준선 확인

사일로와 제품 source workspace가 여러 개 있을 때는 브랜치 이름만으로 최신 기준선을 판단하지 않습니다.

구현, QA 수정, UI 복구, 저장/조회 같은 비즈니스 로직 수정 전에 아래를 확인합니다.

- 같은 프로젝트를 가리키는 repo, worktree, external clone 목록
- 각 workspace의 현재 브랜치, upstream, `HEAD` commit
- 각 workspace의 dirty state와 같은 기능 표면을 건드리는 diff
- task `goal.md`, handoff, 최근 세션 로그에 적힌 보호 브랜치와 작업 위치
- 현재 작업이 이어받아야 하는 source workspace와 폐기 가능한 workspace

서로 다른 worktree가 같은 commit을 가리켜도 dirty diff가 있으면 동일 상태로 보지 않습니다. 특히 sibling task worktree가 같은 화면, API, store, schema, routing, business flow를 수정한 dirty 상태라면 최신 기준선 후보로 보고 먼저 비교합니다.

기준선이 불명확한 상태에서 오래된 workspace에 수정 사항을 덧대지 않습니다. 이 경우 `완료된 것`, `아직 안 된 것`, `기준선 후보`, `선택하지 않은 이유`, `사용자 판단 필요 여부`를 분리해 보고합니다.

## 기능 인벤토리 대조

MVP, QA, 복구, 저장 실패, 화면 누락처럼 기능 완성도가 걸린 작업은 단일 파일 diff만 보지 않고 기능 인벤토리와 현재 코드의 구현 위치를 대조합니다.

기능 인벤토리는 프로젝트마다 다르지만 최소한 아래 단위로 나눕니다.

- 화면 또는 진입 경로
- 사용자 입력과 선택 상태
- API 또는 local store 저장 경로
- 조회와 재진입 시 복원 경로
- validation, empty/error/loading 상태
- 실제 사용자 경로 검증 또는 대체 증거

특정 기능이 반복해서 실패하면 단일 버그로만 처리하지 않습니다. 먼저 해당 기능군이 현재 기준선에 존재하는지, 다른 workspace의 dirty diff에만 존재하는지, PR/commit으로 checkpoint됐는지 확인합니다.

가치 있는 UI 또는 비즈니스 로직이 dirty worktree에만 있으면 다음 작업으로 넘어가기 전에 commit, patch, handoff note 중 하나로 checkpoint합니다. checkpoint 없는 dirty worktree는 정리 대상이 아니라 보존 및 기준선 판단 대상입니다.

## 폐기 가능성

- clone된 작업 공간은 폐기 가능해야 합니다.
- 코드가 크게 망가져도 해당 clone/branch를 폐기하면 됩니다.
- 최종 결과는 PR, report, test evidence 또는 feedback, handoff로만 메인 오케스트레이터에게 제출합니다.

이 구조에서 안전 장치는 수정 제한이 아니라 격리, 브랜치, PR 리뷰, 폐기 가능성입니다.
