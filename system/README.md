# system 디렉토리

이 디렉토리는 `new-human` 작업의 정리 결과물이며, 여러 프로젝트에서 재사용할 수 있는 프롬프트/에이전트 설계 모음집으로 정리합니다.

`new-human` 루트에 흩어져 있던 기존 md 원본들은 성격별로 분리합니다.

- 프로젝트 조사 결과: `../projects/`
- 원본 프롬프트와 과거 초안: `../sources/`

최종 정의와 재사용 가능한 문서는 `system/`를 기준으로 봅니다.

목표는 제품 코드를 고치는 것이 아니라, 다음 흐름을 한국어 문서로 정리하는 것입니다.

```text
레포 파악
-> 사용자가 지금까지 한 일 파악
-> 퍼스널리티 파악
-> 취향 불변성 후보 생성
-> 개인 에이전트 셋업 자료로 승격
```

## 읽는 순서

1. `00-index/현재-상태.md`
2. `00-index/문서-인덱스.md`
3. `00-system-overview/계층-구조와-관리-원칙.md`
4. `00-system-overview/전체-시스템-개요.md`
5. `10-ssot/SSoT-스키마-초안.md`
6. `20-main-orchestrator/메인-오케스트레이터-역할.md`
7. `30-silo-system/동적-사일로-설계.md`
8. `40-pr-review-loop/PR-리뷰와-승격-판단.md`
9. `50-feedback-personality-loop/피드백-기반-퍼스널리티-갱신.md`
10. `60-final-prompts/메인-오케스트레이터-프롬프트-초안.md`

## 폴더 역할

| 폴더 | 역할 |
|---|---|
| `00-index/` | 전체 상태와 문서 색인 |
| `00-system-overview/` | SSoT, 메인 오케스트레이터, 동적 사일로 전체 구조 |
| `10-ssot/` | 상태와 규칙의 원본 스키마 |
| `10-user-analysis/` | 사용자 입력 템플릿 |
| `20-agent-rules/` | 실제 에이전트 규칙으로 승격할 초안 |
| `20-agent-rules/references/` | 에이전트 md 보강에 사용할 프로젝트/PR/보고/퍼스널리티 reference 구조 |
| `20-agent-rules/skill-drafts/` | main 업데이트, SSoT 계층 판단, project SSoT 생성 같은 공통 skill 초안과 사용법 README |
| `20-main-orchestrator/` | 메인 오케스트레이터 역할과 루프 |
| `config/` | 사일로 런타임 env와 프로젝트 설정 템플릿 |
| `profile/` | 개인 프로필 템플릿과 gitignore된 실제 프로필 |
| `scripts/` | 프로젝트 SSoT 같은 반복 구조를 생성하는 공통 스크립트 |
| `30-silo-system/` | 동적 사일로 생성과 작업 방식 |
| `40-pr-review-loop/` | PR 리뷰, 머지, SSoT 승격 판단 |
| `50-feedback-personality-loop/` | 사용자 피드백 기반 규칙 갱신 |
| `60-final-prompts/` | 실제 복붙하거나 설치할 최종 프롬프트 초안 |
| `90-archive/` | 더 이상 중심이 아닌 보관 자료 |

## Git 포함 기준

git에 남길 것은 프로젝트에 독립적인 코어 문서입니다.

포함 대상:

- SSoT, 메인 오케스트레이터, 동적 사일로, PR 리뷰 루프 설계
- 사용자 퍼스널리티와 취향 불변성을 다루는 일반 규칙
- 여러 프로젝트에 적용 가능한 최종 프롬프트 초안
- 한국어 skill/rule 초안
- env/config 템플릿
- 프로젝트별 SSoT 기본 구조를 생성하는 공통 스크립트와 템플릿
- 개인 프로필 템플릿

git에서 제외할 것은 프로젝트 의존 자료와 시크릿성 자료입니다.

제외 대상은 `system/.gitignore`에 정리했습니다.

- `.env`, token, password, credential, secret, private key 계열
- 로컬 실행 로그, trace, 영상, screenshot, cache
- 특정 workspace 분석 자료인 `../projects/`
- 원본 프롬프트와 과거 초안인 `../sources/`
- 프로젝트별 override를 담는 `local/`, `project-local/`, `project-overrides/`, `workspace-local/`
- 실제 프로젝트 목록, 보호 브랜치, clone URL, secret provider 값을 담은 `config/*.env`, `config/silo-projects.yaml`, `config/silo-secrets.yaml`
- 실제 개인 정보와 취향을 담은 `profile/*.local.md`, `profile/personal-profile.md`

## 설정 주입

여러 프로젝트에서 재사용하려면 공통 프롬프트에 프로젝트 의존 값을 직접 박지 않습니다.

대신 아래 템플릿을 사용합니다.

- `config/silo-runtime.env.example`
- `config/silo-projects.example.yaml`

실제 값은 gitignore된 파일이나 secret manager에 둡니다.

- `config/silo-runtime.env`
- `config/silo-projects.yaml`
- `config/silo-secrets.yaml`
- `profile/personal-profile.local.md`

개인 프로필에서 `미입력`인 항목은 추론으로 채우지 않습니다. 사용자가 직접 말했거나, 반복된 PR 피드백으로 충분히 확인된 경우에만 갱신합니다.

## 현재 주의점

- `system/`에는 정의와 템플릿만 둡니다.
- 프로젝트 조사 결과는 기본적으로 fork/submodule/external clone/project SSoT에 둡니다. 로컬 참고 자료는 `../projects/`에 둘 수 있지만 main 커밋 대상은 아닙니다.
- project SSoT의 dashboard, task format, issue format, L 기준, Obsidian plugin 설정이 필요하면 실제 산출물을 main에 커밋하지 않고 `system/scripts/create-project-ssot.mjs` 같은 공통 생성 도구로 만듭니다.
- 원본 프롬프트와 과거 초안은 `../sources/`에 둡니다.
- 이 프롬프트 모음집은 여러 프로젝트에서 쓰는 것이 목표이므로, 프로젝트 의존 자료는 gitignore 대상으로 둡니다.
- 현재 목표 기준 다음 행동은 코드 수정이 아니라, 분석 초안 검토와 규칙 승격입니다.
- 프롬프트와 skill 초안은 한국어로 읽히도록 정리합니다.

## 에이전트 md 보강 방식

`AGENTS.md`, `CLAUDE.md`, 최종 오케스트레이터 프롬프트, 설치용 skill이 빈약하다고 판단되면 바로 규칙을 추가하지 않습니다.

먼저 `20-agent-rules/references/`에 기존 프로젝트 운영 방식, PR 리뷰 반복 피드백, 보고 방식, 퍼스널리티 후보를 reference로 정리합니다. 이후 그 reference에서 반복 근거가 확인된 내용만 공통 규칙으로 압축해 에이전트 md에 반영합니다.

프로젝트 내부 실제 issue/task/QA 결과는 reference에 그대로 복사하지 않고, 해당 project SSoT 위치와 반복 가능한 운영 패턴만 기록합니다.
