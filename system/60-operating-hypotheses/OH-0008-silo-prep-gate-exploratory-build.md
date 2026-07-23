# 사일로 준비 gate와 탐색형 Build 분리 가설

## ID

OH-0008

## 상태

draft

## 기간

- 시작: 2026-07-06
- 종료 또는 폐기:

## 운영 가설

task/issue 사일로 준비 전 상태 갱신 PR 머지를 사일로 실행 상태와 project SSoT 소유권을 보호하는 시작 gate로 두되, 상태 갱신 PR 생성과 그 PR 안의 `in_progress` 상태 diff, 읽기 전용 조사, 대화 안의 실행 계획 초안, 변경안 후보 정리는 `Build -> Learn -> Spec`의 저위험 Build로 허용하면, 보호 gate를 유지하면서도 탐색형 실행 속도를 잃지 않을 수 있다.

## 채택 이유

`system/README.md`는 사일로 root, `goal.md`, repo clone, 작업 브랜치 생성 전에 상태 갱신 PR 머지를 요구했습니다. 반면 `main-v3/main`의 기본 운영 방식은 빠르게 만들고 학습한 뒤 spec으로 승격하는 `Build -> Learn -> Spec`입니다. 두 규칙을 그대로 두면 agent가 상태 갱신 PR 전에는 어떤 조사나 초안도 하면 안 되는지, 또는 반대로 상태 갱신 PR 없이 사일로 실행 상태를 만들어도 되는지 혼동할 수 있습니다.

## 취합한 정보

- 괴리 326: `system/README.md`의 사일로 준비 전 상태 갱신 PR 머지 요구와 루트 탐색형 엔지니어링 정책의 관계가 불명확했습니다.
- 열린 PR 확인: #342, #343, #347은 사일로 하위 문서의 상태 갱신 gate를 다루지만 `system/README.md`의 `Build -> Learn -> Spec` 관계를 직접 정합화하지 않았습니다.
- Codex 리뷰 지적: 이번 변경은 사일로 운영 방식의 적용 한계를 새로 정의하므로 운영 가설 기록이 필요하다는 P1 지적이 있었습니다.

## 기존 방식의 문제

- 상태 갱신 PR 머지가 선행 설계 요구처럼 읽히면 저위험 조사와 초안화까지 멈춰 탐색형 실행 속도가 떨어질 수 있습니다.
- `Build -> Learn -> Spec`을 너무 넓게 해석하면 project SSoT 원문 상태 변경, 사일로 root 생성, repo clone, 작업 브랜치 생성 같은 실행 상태 변경이 gate 없이 진행될 수 있습니다.
- gate 적용 근거가 운영 가설로 남지 않으면 이후 사일로 준비 실패나 drift가 생겼을 때 어떤 판단 기준이 병목을 만들었는지 추적하기 어렵습니다.

## 예상 병목

- 읽기 전용 조사와 사일로 준비 산출물 생성의 경계가 작업마다 다르게 해석될 수 있습니다.
- 상태 갱신 PR 생성과 그 PR 안의 `in_progress` 상태 diff를 작은 Build로 허용해도, 머지 권한이나 project 계층 브랜치 상태 때문에 실제 사일로 준비가 지연될 수 있습니다.
- 다른 PR이 `system/README.md`의 같은 주변 문단을 수정하고 있어 merge conflict가 날 수 있습니다.

## 적용한 작업 방식

- 상태 갱신 PR 머지는 사일로 실행 상태와 project SSoT 소유권을 보호하는 시작 gate로 표현합니다.
- 상태 갱신 PR 생성과 그 PR 안의 `in_progress` 상태 diff, 읽기 전용 조사, 대화 안의 실행 계획 초안, 변경안 후보 정리는 합리적 추정으로 진행 가능한 범위로 둡니다.
- 보호 브랜치 직접 수정, secret/credential 또는 production 데이터 접근, destructive action, 상태 갱신 PR 범위를 넘는 project SSoT 원문 변경, 사일로 root/`goal.md`/repo clone/작업 브랜치 생성은 상태 갱신 PR 머지 확인 전 금지로 둡니다.

## 적용 범위

- 0계층 `system/README.md`의 사일로 준비 gate 설명
- task/issue 사일로 시작 전 상태 갱신 PR 판단
- `Build -> Learn -> Spec` 기본값을 사일로 준비 전 단계에 적용할 때의 위험 분류

## 실행 결과

- PR #377에서 `system/README.md`와 사일로 절차 문서에 상태 갱신 PR gate와 탐색형 Build의 관계를 반영했습니다.
- PR #377 Codex 리뷰에서 운영 가설 기록 누락이 P1로 지적되어 이 문서를 추가했습니다.

## 실제 병목

- 초기 변경은 `system/README.md`만 수정해 운영 방식 변경 근거가 누락됐습니다.
- `system/README.md`를 수정하는 열린 PR이 많아 머지 시점에 충돌 해결이 필요할 수 있습니다.

## 사람 확인 지점

- 상태 갱신 PR 생성과 그 PR 안의 `in_progress` 상태 diff를 작은 Build로 보는 해석이 실제 사일로 실행에서 과도한 대기나 권한 충돌을 만들지 확인해야 합니다.
- 읽기 전용 조사와 준비 산출물 생성의 경계가 충분히 명확한지 확인해야 합니다.
- project 계층 메인 브랜치 머지 권한이 없을 때 사일로 진행 중단 보고가 과도하게 빈번해지는지 확인해야 합니다.

## 유지할 것

- 사일로 실행 상태를 만드는 행위는 상태 갱신 PR 머지 후에만 진행하는 gate
- 저위험 조사와 초안화는 `Build -> Learn -> Spec`의 합리적 추정 범위로 두는 분리
- secret, credential, production 데이터, destructive action, 보호 브랜치 직접 수정 금지

## 버릴 것

- 상태 갱신 PR 머지 전에는 모든 조사와 초안화를 멈추는 해석
- `Build -> Learn -> Spec`을 이유로 상태 갱신 PR 범위를 넘는 project SSoT 원문 변경이나 사일로 준비 산출물 생성을 gate 없이 진행하는 해석
- 운영 방식 변경을 README 문구에만 남기고 운영 가설 기록을 생략하는 방식

## 0계층 반영 위치

- 문서: `system/README.md`, `system/30-silo-system/README.md`, `system/30-silo-system/02-silo-goal.md`, `system/30-silo-system/20-silo-workflow/normal.md`, `system/60-operating-hypotheses/OH-0008-silo-prep-gate-exploratory-build.md`
- skill:
- agent prompt: `system/10-agents/main-orchestrator/README.md`, `system/10-agents/main-orchestrator/main-prompt.md`

## 후속 운영 가설 후보

- 상태 갱신 PR 생성과 머지 확인을 자동화하면 사일로 준비 시작 지연이 줄어드는가
- 읽기 전용 조사와 준비 산출물 생성을 체크리스트로 분리하면 gate 오해가 줄어드는가
