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

## 폐기 가능성

- clone된 작업 공간은 폐기 가능해야 합니다.
- 코드가 크게 망가져도 해당 clone/branch를 폐기하면 됩니다.
- 최종 결과는 PR, report, evidence, handoff로만 메인 오케스트레이터에게 제출합니다.

이 구조에서 안전 장치는 수정 제한이 아니라 격리, 브랜치, PR 리뷰, 폐기 가능성입니다.
