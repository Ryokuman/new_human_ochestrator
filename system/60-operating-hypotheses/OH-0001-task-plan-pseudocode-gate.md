# 기능 task 사전 계획 리뷰 가설

## ID

OH-0001

## 상태

active

## 기간

- 시작: 2026-06-26
- 종료 또는 폐기:

## 운영 가설

기능 task를 바로 사일로 구현으로 넘기지 않고, 먼저 project contract를 확인한 뒤 task 계약, 단계별 구현 계획, pseudo code를 작성하게 하고 이를 리뷰하면 목표 밖 화면, API, DB mutation, submodule, E2E 범위 drift를 구현 전에 발견할 수 있다.

## 채택 이유

이전 방식은 프로젝트가 무엇인지, 현재 버전의 목표와 비목표가 무엇인지, FE/BE/DB/harness/submodule이 어떤 역할을 가져야 하는지 충분히 압축하지 않은 채 task를 밀어넣었다. 그 결과 구현 결과와 화면을 보고 나서야 drift가 드러났다. 그러면 이미 PR, submodule, harness, 사용자 확인이 얽힌 뒤라 폐기 비용이 커졌다.

project contract, 계획, pseudo code를 먼저 리뷰하면 실제 코드를 쓰기 전에 구현 범위, 데이터 흐름, 화면 상태 변화, 검증 경로를 비교할 수 있다.

## 취합한 정보

- 사용자 피드백: task를 밀어넣고 구현 계획을 단계별로 세우게 한 뒤 pseudo code를 리뷰하면 drift가 먼저 보인다.
- 사용자 피드백: task를 만들기 이전에 프로젝트가 무엇인지 설명하는 부분도 확실히 필요하며, 이 부분이 충분히 성숙하지 못했다.
- 반복 관찰: 구현 결과물 확인 시점에 목표 밖 화면, 불필요한 기능, 디자인 톤 이탈, human check 병목이 뒤늦게 드러났다.
- 반복 관찰: project SSoT에는 repo 역할, DB, submodule, design 관련 정보가 있었지만 task 생성자가 먼저 읽을 project-level 계약으로 충분히 압축되어 있지 않았다.
- PR 리뷰 관찰: 규칙을 agent prompt에만 넣으면 README, goal template, scaffold 같은 다른 진입점에서 누락된다.

## 기존 방식의 문제

- task 생성 전에 project contract 확인 단계가 없었다.
- project SSoT 안에 정보가 있어도 task 생성자가 먼저 확인할 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, FE/BE/DB/harness/submodule 역할 요약이 부족했다.
- task 생성과 구현 사이에 검토 가능한 중간 산출물이 부족했다.
- 구현자 또는 사일로가 task 목표를 넓게 해석해도 코드가 나온 뒤에야 알 수 있었다.
- human check가 "결과물 승인" 단계에 몰려 병목이 커졌다.
- project contract 누락인지, task 계약 누락인지, 계획 누락인지, task-writer, main-orchestrator, goal template, PR 본문 중 어디에서 발생했는지 추적하기 어려웠다.

## 예상 병목

- project contract가 너무 길거나 task별 세부사항을 포함하면 다시 task 생성 전 병목이 된다.
- project contract가 추상적이면 task 생성자가 여전히 제품 정의, 디자인 톤, DB/API 계약을 추정한다.
- pseudo code 상세도가 너무 낮으면 drift를 잡지 못한다.
- pseudo code 상세도가 너무 높으면 사실상 구현 전 코드 리뷰가 되어 속도가 느려진다.
- 비기능 task에까지 pseudo code를 강제하면 불필요한 절차가 된다.
- README, prompt, scaffold, goal template 중 하나라도 빠지면 새 규칙이 우회된다.

## 적용한 작업 방식

- 기능 task를 만들기 전에 project contract를 확인한다.
- project contract에는 제품 정의, 현재 버전 목표/비목표, 핵심 사용자 플로우, FE/BE/DB/harness/submodule 역할, 디자인 톤 정본, 추정 금지 정보를 둔다.
- task 계약은 project contract에서 확인된 정보만 사용하고, 누락된 정보는 임시 추정으로 채우지 않고 `project contract 누락`으로 표시한다.
- 기능 task에만 단계별 구현 계획과 pseudo code를 요구한다.
- pseudo code는 실제 코드가 아니라 파일, 함수, API, DB mutation, 화면 상태 변화가 보이는 수준으로 제한한다.
- 목표 밖 화면, 버튼, endpoint, table mutation, submodule, E2E 범위가 나오면 `범위 drift 후보`로 표시한다.
- 역할 README, main-prompt, AGENTS, 사일로 goal spec, project SSoT scaffold를 함께 갱신한다.

## 적용 범위

- project contract 확인
- 기능 task 작성
- 기능 task 사일로 준비
- main-orchestrator 실행 판단
- task-writer 산출물
- 사일로 `goal.md`

## 실행 결과

- 0계층 규칙에 기능 task 사전 계획 리뷰 gate가 추가됐다.
- Codex PR 리뷰에서 누락된 README와 goal template 연결이 지적됐고, 이를 반영했다.
- 최신 head 기준 no-major 리뷰를 통과한 뒤 main-v2에 반영됐다.
- 후속 검토에서 task 생성 이전의 project contract 압축 부족이 추가 병목으로 확인됐다.

## 실제 병목

- 초기 반영은 task 생성 이후의 계획 리뷰에 초점이 있었고, task 생성 전에 project contract를 확인하는 단계가 빠져 있었다.
- 처음 반영 시 pseudo code 요구가 비기능 task까지 확장될 위험이 있었다.
- 역할 main-prompt만 바꾸고 README를 놓치는 진입점 불일치가 있었다.
- goal template과 scaffold를 함께 갱신하지 않으면 새 사일로에서 규칙이 우회될 수 있었다.

## 사람 확인 지점

- project contract가 task 생성자가 빠르게 확인할 수 있는 수준으로 충분히 압축됐는지 확인해야 한다.
- pseudo code가 리뷰 가능한 충분한 수준인지 판단하는 기준은 아직 사용자 피드백을 더 받아야 한다.
- 기능 task마다 계획 리뷰를 어느 시점에 승인으로 볼지 기준이 더 필요하다.

## 유지할 것

- task 생성 전 project contract 확인 단계
- 실패 원인을 project contract 누락, task 계약 누락, 계획/pseudo code 누락으로 분리하는 방식
- 기능 task에 한정한 단계별 구현 계획과 pseudo code gate
- 목표 밖 산출물을 `범위 drift 후보`로 먼저 표시하는 방식
- prompt, README, template, scaffold를 함께 갱신하는 방식

## 버릴 것

- 비기능 task에 pseudo code를 기계적으로 요구하는 방식
- 구현 결과를 본 뒤에야 목표 drift를 판단하는 방식
- project SSoT에 정보가 있다는 이유만으로 task 생성자가 충분히 이해했다고 가정하는 방식
- project별 실제 task 원문을 0계층에 복사해 운영 가설로 착각하는 방식

## 0계층 반영 위치

- 문서: `AGENTS.md`, `system/README.md`, `system/30-silo-system/02-silo-goal.md`
- skill:
- agent prompt: `system/10-agents/main-orchestrator/`, `system/10-agents/task-writer/`

## 후속 운영 가설 후보

- submodule PR 평가를 먼저 통과시키고 제품 repo는 pin만 하게 하면 제품 PR human check 병목이 줄어드는가
- Codex review loop를 agent가 자동 대기/수정/재요청하면 사용자의 리뷰 호출 관리 부담이 줄어드는가
- version/operating hypothesis를 PR 전에 작성하면 프로젝트 구현 플랜 drift가 줄어드는가
