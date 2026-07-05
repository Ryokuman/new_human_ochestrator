# GitHub 프로젝트 수집 evidence pack 운영 가설

## ID

OH-0005

## 상태

active

## 기간

- 시작: 2026-07-03
- 종료 또는 폐기:

## 운영 가설

GitHub 원격 정보와 로컬 repo 근거를 같은 intake 절차에서 수집하고, `적용`, `보류`, `영구제외`, repo bundle, evidence pack으로 나누면 포트폴리오나 project SSoT 후보를 빠르게 만들면서도 공개 가능성, 권한, 추론 여부를 분리할 수 있습니다.

## 채택 이유

프로젝트 후보를 조사할 때 GitHub description, README, repo 이름, 로컬 코드 확인, 사용자 분류 결정이 섞이면 어떤 항목이 공개 가능한 사실인지 추적하기 어렵습니다. repo 단위 inventory와 프로젝트 단위 evidence pack을 분리하면 빠른 초안 작성과 검증 근거 관리를 동시에 할 수 있습니다.

## 취합한 정보

- GitHub owner, organization, repo URL, visibility, default branch, pushed date, language, topic, PR 이력
- 로컬 clone 경로, README, package, 실행 문서, commit, PR, issue, 코드 경로
- 사용자 분류 결정: `적용`, `보류`, `영구제외`, repo 묶음
- 공개하면 안 되는 private repo 원문, secret, 회사 내부 정보 경계

## 기존 방식의 문제

- repo 목록을 한 번에 모두 설명하려 해 사용자가 10개 단위로 분류하기 어렵습니다.
- FE, BE, support repo가 타이틀 프로젝트와 중복 포트폴리오 항목으로 남을 수 있습니다.
- GitHub 원격 근거와 로컬 코드 근거가 섞여 `확인됨`, `부분 확인`, `추론`, `확인 필요`의 차이가 흐려집니다.
- private repo의 민감한 원문이 공개 문구 초안으로 넘어갈 위험이 있습니다.

## 예상 병목

- GitHub 인증 계정과 접근 권한이 owner 또는 organization마다 달라 repo 누락과 접근 불가를 구분해야 합니다.
- repo 수가 많으면 사용자 분류 결정이 지연될 수 있습니다.
- 로컬 clone이 없거나 오래된 경우 GitHub 원격 정보만으로는 프로젝트 성격을 확정할 수 없습니다.
- 같은 제품의 FE, BE, infra, harness repo를 묶는 근거가 부족하면 bundle 판단이 흔들릴 수 있습니다.

## 적용한 작업 방식

`github-project-intake` skill에서 계층 판정, 인증 확인, owner와 organization 수집, repo inventory 작성, 10개 단위 분류, project bundle, evidence pack, 신뢰도 표시, 자기검수를 순서대로 수행합니다.

## 적용 범위

- GitHub 계정, organization, repo URL, local clone 경로 기반 프로젝트 조사
- 포트폴리오 SSoT 또는 project SSoT에 넣을 프로젝트 근거 정리
- 공통 운영 절차와 repo skill 문서화가 필요한 0계층 변경

## 실행 결과

PR #194에서 `github-project-intake` repo skill, skill README 연결, system README 연결을 추가했습니다. 실행 결과는 실제 프로젝트 조사 적용 후 이어서 기록합니다.

## 실제 병목

아직 실제 프로젝트 조사 세션에서 검증하지 않았습니다. PR 리뷰에서는 `visibility` 필드 누락, 기본 프롬프트의 skill 명시 부족, 운영 가설 원문 누락이 먼저 발견됐습니다.

## 사람 확인 지점

- 어떤 repo를 `적용`, `보류`, `영구제외`로 둘지
- private repo 내용을 공개 가능한 포트폴리오 문구로 추상화할 수 있는지
- FE, BE, support repo를 같은 타이틀 프로젝트로 묶을지
- project SSoT 또는 portfolio SSoT의 실제 저장 위치와 기준 브랜치

## 유지할 것

- repo inventory와 evidence pack 분리
- 원격 근거, 로컬 근거, agent 추론, 사용자 결정을 분리하는 보고 방식
- `확인됨`, `부분 확인`, `추론`, `확인 필요` 신뢰도 표시
- private repo 원문과 공개 문구를 분리하는 금지선

## 버릴 것

- GitHub description 또는 README만으로 프로젝트 성격을 확정하는 방식
- FE, BE, support repo를 별도 항목으로 중복 나열하는 방식
- 사용자 분류 결정 없이 모든 repo를 포트폴리오 후보로 남기는 방식

## 0계층 반영 위치

- 문서: `system/README.md`, `system/20-skills/README.md`, `system/60-operating-hypotheses/OH-0005-github-project-intake.md`
- skill: `system/20-skills/github-project-intake/SKILL.md`
- agent prompt: `system/20-skills/github-project-intake/agents/openai.yaml`

## 후속 운영 가설 후보

- 실제 포트폴리오 조사 세션에서 10개 단위 분류가 사용자 판단 병목을 줄이는지 검증합니다.
- repo bundle 기준이 부족할 때 product-level contract 또는 project SSoT 요구사항으로 승격하는 기준을 정리합니다.
