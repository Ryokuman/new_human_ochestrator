---
name: projects-setup
description: 새 프로젝트를 root orchestrator의 projects 구조에 등록하거나 기존 프로젝트에 프로젝트 SSoT scaffold, 사일로 로컬 공간, silo project config를 셋업해야 할 때 사용합니다.
---

# Projects Setup

이 스킬은 새 프로젝트를 1계층 `projects/<project-id>/`에 등록하고, 2계층 Project Internal SSoT와 3계층 Silo Local 공간을 한 번에 준비합니다.

## 원칙

- `projects/<project-id>/`는 프로젝트 연결 정보와 프로젝트 의존 운영 자료의 입구입니다.
- `02-project-internal/`은 실제 project SSoT입니다. 이 안의 issue, task, QA, coverage 산출물은 0계층 `system/`으로 복사하지 않습니다.
- `setup.sh --create-project-ssot`은 최소 project SSoT scaffold를 생성합니다. Obsidian/Dataview 같은 viewer 플러그인은 프로젝트별 필요가 확정될 때 별도 처리합니다.
- `system/config/silo-projects.yaml`은 로컬 설정입니다. secret 값은 쓰지 않고, repo URL, 보호 브랜치, 사일로 대상 여부 같은 운영 값만 기록합니다.
- 기존 `project-ssot-bootstrap` 역할은 이 스킬에 흡수되었습니다.

## 기본 구조

```text
projects/<project-id>/
├── README.md
├── 00-secrets/
│   └── README.md
├── 02-project-internal/
│   ├── README.md
│   ├── 00-dashboard/
│   │   └── project-overview.md
│   ├── 10-dictionary/
│   │   └── project-dictionary.md
│   ├── 20-issues/
│   ├── 30-tasks/
│   ├── 50-decisions/
│   ├── 70-handoff/
│   └── 90-coverage/
└── 03-silo-local/
    ├── README.md
    └── pr-description-template.md
```

## 절차

1. 계층을 판정합니다. 공통 규칙 변경이면 `main-branch-update-flow`, 특정 프로젝트 자료면 프로젝트 SSoT 또는 project 브랜치에서 처리합니다.
2. `project-id`, 표시 이름, repo URL, default branch, 보호 브랜치, `allowed_for_silo`, `role`을 확인합니다.
3. `projects/<project-id>/`가 이미 있거나 `silo-projects.yaml`에 같은 id가 있으면 중단하고 병합/갱신 여부를 확인합니다.
4. `02-project-internal` scaffold는 `setup.sh`로 생성합니다.

```bash
./setup.sh --create-project-ssot \
  --project-id sample-project \
  --project-name "Sample Project" \
  --target projects/sample-project/02-project-internal \
  --yes
```

5. `projects/<project-id>/README.md`, `00-secrets/README.md`, `03-silo-local/README.md`, `03-silo-local/pr-description-template.md`를 생성합니다.
6. `system/config/silo-projects.yaml`이 없으면 `./setup.sh --init-config --yes`로 local config 초안을 만듭니다. 있으면 기존 구조를 보존하고 `projects:` 항목에 새 프로젝트만 추가합니다.
7. 변경 후 `git diff --stat`, 생성 파일 목록, config 등록 항목을 보고합니다.

## 필수 프로젝트 설명 산출물

모든 project SSoT에는 프로젝트 전반 설명과 dictionary가 있어야 합니다.

`00-dashboard/project-overview.md`에는 최소 아래 항목을 둡니다.

- 프로젝트 목적
- 주요 사용자/운영자
- repo/SSoT 위치
- 주요 workflow
- 검증/배포/운영 경계
- 금지선/주의사항

`10-dictionary/project-dictionary.md`에는 프로젝트에서 쓰는 용어, 고유명사, 내부 약어, runner 용어, coverage 용어를 기록합니다. 최소 필드는 아래와 같습니다.

| 필드 | 설명 |
|---|---|
| 용어/고유명사/내부 약어 | 프로젝트에서 실제 쓰는 이름 |
| 뜻 | 처음 보는 사람이 이해할 수 있는 정의 |
| 사용 맥락 | 어느 workflow, repo, runner, 화면, 문서에서 쓰는지 |
| 예시 | 실제 표현이나 page/item 예시 |
| 출처 또는 확인 상태 | source 문서, PR, 사용자 확인, 추정 여부 |
| 프로젝트 전용인지 공통 승격 후보인지 | project-local 용어인지, root `main-v2` 공통 규칙 후보인지 |

PR 본문 `명사 설명`에 반복해서 등장한 용어는 project dictionary 승격 후보로 남깁니다. 여러 프로젝트에서 반복되거나 에이전트 공통 행동 규칙에 영향을 주는 용어만 root `main-v2` 공통 dictionary 또는 관련 system 문서 승격 후보로 분리합니다.

Project dictionary 파일을 새로 만들거나 기존 dictionary에 용어를 추가/수정/삭제하는 PR은 PR 본문에 `새로 추가된 단어` 섹션을 둡니다.

- `명사 설명`은 해당 PR을 이해하기 위한 즉시 설명입니다.
- `새로 추가된 단어`는 project dictionary SSoT에 실제 추가/수정/삭제된 용어 목록입니다.
- 최소 컬럼은 `변경 유형`, `용어`, `뜻`, `사용 맥락`, `프로젝트 전용/공통 후보`, `dictionary 위치`입니다.
- 신규 추가만 있으면 `변경 유형`을 `추가`로 적고, 수정/삭제가 있으면 같은 컬럼에 `수정` 또는 `삭제`로 표시합니다.
- PR에서 설명한 용어가 장기 재사용될 용어라면 dictionary 승격 후보 또는 실제 dictionary 변경으로 이어져야 합니다.

## config 등록 규칙

`system/config/silo-projects.yaml` 프로젝트 항목은 최소 아래 필드를 포함합니다.

```yaml
- id: sample-project
  name: Sample Project
  repo_url: git@github.com:ORG/sample-project.git
  default_branch: main
  protected_branches:
    - main
  allowed_for_silo: true
  role: app
  notes:
    - projects-setup으로 등록했습니다.
```

- `repo_url`에 token, password, 개인 access key를 넣지 않습니다.
- secret provider, credential 경로, 실제 secret 값은 `00-secrets/README.md`에 계약만 적고 값을 기록하지 않습니다.
- 공용 서비스는 `allowed_for_silo: false`와 `service_policy.owner: main-orchestrator`를 명시합니다.
- 동일 id가 이미 있으면 덮어쓰지 않습니다.

## 검증

```bash
bash -n setup.sh
tmp="$(mktemp -d)"
./setup.sh --create-project-ssot --project-id sample --target "$tmp/sample-ssot" --yes
test -f "$tmp/sample-ssot/README.md"
```

생성 후 확인할 것:

- `projects/<project-id>/README.md`
- `projects/<project-id>/00-secrets/README.md`
- `projects/<project-id>/02-project-internal/00-dashboard/project-overview.md`
- `projects/<project-id>/02-project-internal/10-dictionary/project-dictionary.md`
- `projects/<project-id>/03-silo-local/pr-description-template.md`
- `system/config/silo-projects.yaml`의 프로젝트 id 중복 없음

## 금지

- project issue, task, QA, coverage run/report 원문을 0계층 `system/`에 복사하지 않습니다.
- secret, token, password, credential 값을 문서나 config에 기록하지 않습니다.
- 보호 브랜치에서 직접 제품 코드 작업을 시작하지 않습니다.
- setup scaffold 생성 실패를 무시하고 완료로 보고하지 않습니다. 실패하면 경로/권한/기존 파일 충돌을 분리해 보고합니다.
