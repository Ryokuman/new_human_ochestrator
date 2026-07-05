# 사일로 유형

사일로는 산출물 성격에 따라 `테스트 사일로`와 `일반 사일로`로 구분합니다.

| 유형 | 주 산출물 | 대표 용도 | 기본 정리 기준 |
|---|---|---|---|
| 테스트 사일로 | 개별 보고서, test evidence, 전체 사일로 보고서, issue/task 승격 후보 | lifecycle 테스트, E2E 검증, runtime 검증, 탐색 검증 | 보고서와 test evidence 승격 gate 통과 후 삭제 가능 |
| 일반 사일로 | 변경 diff, PR, patch, test evidence, handoff | 구현, 수정, 문서, repair, conflict, PR 작업 | PR/patch 대응 관계와 작업트리 상태 확인 후 보존 또는 정리 |

테스트 사일로는 보고서가 주 산출물인 임시 실행 환경입니다.

일반 사일로는 변경/PR/patch/test evidence가 주 산출물인 작업 환경입니다. 테스트 사일로의 자동 삭제 규칙을 일반 사일로에 적용하지 않습니다.

일반 사일로 내부에서 QA, 테스트, 브라우저 검증을 실행할 수 있습니다. 이 경우에도 주 산출물이 변경 diff, PR, patch, handoff라면 일반 사일로로 유지합니다.

project가 시작된 뒤 생성되는 task, issue, QA, runbook, coverage, work dashboard, Run Set은 2계층 `Project Work SSoT`에 속합니다. 이 root 저장소에는 실제 project work 데이터가 없을 수 있으므로, 사일로 유형은 root `system/` 문서 존재 여부가 아니라 해당 project SSoT와 사일로 주 산출물 기준으로 판정합니다.

2계층 `Project Work SSoT`를 수정하는 일반 사일로는 독립 merge target을 만들지 않습니다. 변경은 해당 project의 project 계층 메인 브랜치로 돌아가는 작업 범위입니다. 목표 모델에서는 `project-{projectName}/main`에서 판 `project-{projectName}/{taskname}` 작업 브랜치와 PR로 회수합니다. 현재 호환 상태에서는 `project-{projectName}`와 `project-{projectName}-{taskname}`을 사용합니다.

사일로 유형은 내부에서 어떤 worker를 호출했는지가 아니라 최종 주 산출물로 판정합니다.

`Hypothesis Chain`은 일반 사일로에만 적용합니다. 테스트 사일로의 실패 원인 후보는 report/test evidence 쪽에 남기고, task 내부 구현 가설 체인으로 이어가지 않습니다.
