---
name: github-project-intake
description: GitHub 계정, 조직, repo URL, 로컬 프로젝트 repo 위치를 바탕으로 포트폴리오나 project SSoT에 쓸 프로젝트 정보와 근거를 수집해야 할 때 사용합니다. gh 인증 계정 전환, 개인/조직 repo 조사, 적용/보류/영구제외 분류, FE/BE/도구 repo 묶음, 프로젝트별 설명/아키텍처/이슈/역할 근거 정리에 적용합니다.
---

# GitHub 프로젝트 수집

## 개요

GitHub 원격 정보와 로컬 repo 위치를 함께 사용해 프로젝트 후보를 빠짐없이 수집하고, 포트폴리오나 project SSoT에 넣을 수 있는 검증된 근거 묶음으로 정리합니다.

핵심은 `원격에서 발견한 사실`, `로컬 코드로 확인한 사실`, `agent 추론`, `사용자 분류 결정`을 섞지 않는 것입니다.

## 입력 계약

사용자가 아래 중 일부만 줘도 진행하되, 누락 항목은 `확인 필요`로 분리합니다.

- GitHub 계정: 예를 들어 `Ryokuman`, `kimyonmin`
- 사용할 `gh` 인증 계정 또는 전환 대상 계정
- 조사할 owner, organization, repo URL, local clone 경로
- project SSoT 또는 project-level portfolio/evidence 요약 기준 경로
- 이미 결정된 `적용`, `보류`, `영구제외`, `묶음` 규칙
- 공개하면 안 되는 repo, secret, 회사 내부 정보 경계

## 금지선

- `gh auth status` 출력에서 token 값은 절대 기록하지 않습니다.
- `.env`, credential, secret, private key, production 데이터는 읽거나 복사하지 않습니다.
- private repo의 민감한 원문은 포트폴리오 문구로 바로 쓰지 않고, 공개 가능한 추상화 문장과 근거 위치로 분리합니다.
- GitHub description, README, repo 이름만 보고 프로젝트 성격을 확정하지 않습니다. 로컬 코드, PR, commit, issue, 실행 문서 중 하나 이상으로 보강합니다.
- 닫힌 PR과 merged PR을 같은 완료 근거로 취급하지 않습니다.
- 사용자의 `영구제외` 결정은 다시 포트폴리오 후보로 올리지 않습니다. 단, 타이틀 프로젝트에 포함되는 하위 FE/BE/support repo인지 확인하라는 별도 지시가 있으면 묶음 근거로만 검토합니다.
- project SSoT나 project-level portfolio/evidence 요약에 쓰기 전에는 계층과 기준 브랜치를 먼저 판정합니다.

## 절차

1. 계층과 저장 위치를 판정합니다.
   - 공통 skill, template, agent 규칙이면 0계층입니다. 목표 기준은 `main-v3/main`, 현재 호환 기준은 `main-v3/main`입니다.
   - 특정 project나 portfolio 설명을 쓰더라도 별도 portfolio 계층을 새로 만들지 않습니다. 특정 프로젝트에 연결되는 portfolio/evidence 요약은 해당 project 계층 자료로 보고, 목표 기준은 `project-{projectName}/main`, 현재 호환 기준은 `project-{projectName}`입니다.
   - 1계층 Project SSoT에는 project-level 요약, 공개 가능성, repo 묶음, 근거 위치 색인, 사용자 역할 요약만 둡니다. PR/commit/code path 원문, 캡처 파일, 실행 로그, task별 검증 증거, 문제 해결 상세는 2계층 Project Work SSoT, 3계층 사일로/로컬 evidence, PR 본문, 또는 project가 정한 외부 evidence 위치로 내립니다.
   - 로컬 조사 산출물은 사용자가 승인하기 전까지 commit 대상과 분리합니다.

2. `gh` 인증 상태와 계정을 확인합니다.
   - `gh auth status`로 로그인 계정과 scope를 확인합니다.
   - 필요한 계정이 비활성 상태면 `gh auth switch -u <account>`로 전환합니다.
   - 인증 실패, 권한 부족, private repo 접근 실패는 repo 누락이 아니라 `접근 불가`로 기록합니다.

3. owner와 organization을 수집합니다.
   - 사용자가 준 owner를 먼저 조사합니다.
   - 가능한 경우 `gh api user/orgs`, `gh api users/<user>/orgs`, `gh repo list <owner>`로 참가 organization과 repo 후보를 넓힙니다.
   - organization 내부 repo는 `owner`, `접근 계정`, `visibility`, `권한 확인 여부`를 함께 남깁니다.

4. repo inventory를 만듭니다.
   - 권장 필드: `번호`, `nameWithOwner`, `url`, `visibility`, `primaryLanguage`, `defaultBranch`, `pushedAt`, `description`, `localPath`, `source`, `confidence`, `분류`.
   - 예시 명령:

```bash
gh repo list <owner> --limit 1000 --json nameWithOwner,isPrivate,visibility,primaryLanguage,defaultBranchRef,pushedAt,url,description
gh repo view <owner>/<repo> --json nameWithOwner,isPrivate,visibility,primaryLanguage,defaultBranchRef,pushedAt,url,description,repositoryTopics
gh pr list --repo <owner>/<repo> --author <account> --state all --limit 100 --json number,title,state,mergedAt,createdAt,updatedAt,headRefName,baseRefName,url
```

5. 사용자가 10개 단위로 분류하기 쉽게 보고합니다.
   - 번호는 세션 중 안정적으로 유지합니다.
   - 사용자의 답변 `적용`, `보류`, `영구제외`를 원문 그대로 반영합니다.
   - `1/3`, `12/17`처럼 슬래시로 온 답변은 해당 번호 다건 선택으로 해석합니다.
   - 이미 분류된 repo를 다시 묻지 말고, 새로 발견된 repo만 다음 묶음으로 제시합니다.

6. 관련 repo를 프로젝트 단위로 묶습니다.
   - 타이틀이 되는 제품 repo가 `적용`이면 FE, BE, API, docs, style, infra, harness repo는 별도 포트폴리오 항목이 아니라 하위 근거로 묶습니다.
   - 같은 제품의 legacy, prototype, predecessor는 사용자가 허용한 경우에만 `전신`, `실험`, `하위 모듈`로 넣습니다.
   - standalone library나 testing tool은 제품 repo와 목적이 다르면 별도 프로젝트로 남깁니다.
   - 이름이 비슷하다는 이유만으로 묶지 말고 README, package name, PR/commit, import 관계, 배포/실행 문서 중 하나로 연결 근거를 확인합니다.

7. 적용 프로젝트별 project-level portfolio/evidence 요약과 선택적 evidence pack 경계를 먼저 분기합니다.
   - portfolio를 별도 계층으로 만들지 않습니다. 사용자가 별도 portfolio SSoT 기준 경로와 템플릿을 준 경우에만 그 기준을 따르며, Project SSoT 기본 구조를 새로 만들도록 유도하지 않습니다.
   - 1계층 Project SSoT의 overview/registry 또는 project가 별도 지정한 root index: 한 줄 정체성, 제품 목적, repo 묶음, 현재 공개 가능성, 확인 상태, 사용자 역할, Project SSoT와 Project Work SSoT 위치만 둡니다.
   - `01-project-ssot/project-registry.md`: repo/source 위치, GitHub 원격, 기본 브랜치, 보호 브랜치, 공개 가능성, 접근 확인 상태를 둡니다.
   - `01-project-ssot/AGENTS.md`: 제품 정의, 현재 버전 목표와 비목표, 핵심 사용자 플로우, 데이터 저장과 동기화 경계, repo 역할, 추정 금지 정보를 둡니다.
   - `01-project-ssot/10-requirements/`: 기능/사용자 흐름별 요구사항과 그 흐름이 사용하는 runtime, DB, API, auth 계약 및 정본 위치를 둡니다.
   - `01-project-ssot/50-decisions/`: 아키텍처 선택, 대안, trade-off와 채택·폐기 근거를 둡니다.
   - `01-project-ssot/work-ssot-index.md`: issue, task, runbook, coverage, handoff, evidence 원문이 있는 2계층 위치를 색인합니다.
   - `02-project-work-ssot/` 또는 이전 호환 `02-project-internal/`: 프로젝트 상태, 운영 경계, 진행 중 생긴 문제, 해결 방식, 남은 리스크, 재현 근거, task, runbook, handoff, coverage, 테스트와 검증 근거를 둡니다.
   - PR/commit/code path 원문, 캡처, 테스트 evidence, 실행 로그는 2계층 Project Work SSoT, 3계층 사일로/로컬 evidence, PR 본문, 또는 project가 정한 외부 evidence 위치로 내립니다.
   - 범용 `01-project-ssot/references/`를 만들지 않습니다. 외부 링크는 링크를 사용하는 registry, requirement, decision, task 또는 evidence 문서 안에 둡니다.
   - `architecture/`, `issues/`, `ownership/`, `images/`, `metrics/`, `evidence/` 같은 evidence pack 폴더는 `projects-setup` 기본 scaffold가 아닙니다. 필요하면 project 정책이 정한 2계층 Project Work SSoT 하위 확장, 3계층 사일로/로컬 evidence, PR 본문, 또는 외부 evidence 위치로 명시합니다.
   - 여러 프로젝트에서 같은 evidence pack 구조가 반복 필요하다고 확인되기 전에는 0계층 scaffold에 새 폴더를 추가하지 않습니다. 반복 필요가 확인되면 별도 scaffold 후보로 분리합니다.

8. 프로젝트 정보의 신뢰도를 표시합니다.
   - `확인됨`: GitHub와 로컬 코드/문서 근거가 함께 있습니다.
   - `부분 확인`: 원격 근거 또는 로컬 근거 중 하나만 있습니다.
   - `추론`: 이름, 구조, 과거 대화로 추정했지만 직접 근거가 부족합니다.
   - `확인 필요`: 사용자나 private 자료 확인 없이는 확정하면 안 됩니다.

9. 작성 전 자기검수를 수행합니다.
   - 적용 프로젝트 수, 보류 수, 영구제외 수가 사용자 결정과 맞는지 확인합니다.
   - `영구제외` repo가 포트폴리오 항목으로 남아 있지 않은지 확인합니다.
   - FE/BE/support repo가 타이틀 프로젝트와 중복 항목으로 남아 있지 않은지 확인합니다.
   - secret, token, `.env`, private key, production 데이터가 diff에 없는지 확인합니다.
   - `확인됨`이라고 쓴 문장마다 근거 링크나 로컬 파일 경로가 있는지 확인합니다.

## 보고 형식

조사 보고는 아래 순서를 기본으로 합니다.

- 발견한 owner와 organization
- 접근 가능 repo 수와 접근 불가 repo 수
- 10개 단위 repo 목록과 현재 분류
- 새로 묶은 프로젝트 bundle
- 적용 프로젝트별 확인된 정보: 설명, repo 묶음, 아키텍처 단서, 이슈 단서, 사용자가 맡은 일 단서, 이미지 전략
- 누락 정보와 다음 확인 질문
- 쓴 파일, 쓰지 않은 로컬 조사 파일, commit/PR 여부

## 검증 명령

상황에 맞게 일부 또는 전체를 실행합니다.

```bash
gh auth status
gh repo list <owner> --limit 1000 --json nameWithOwner,isPrivate,visibility,primaryLanguage,defaultBranchRef,pushedAt,url,description
git status --short --branch
git diff --check
rg -l "token|password|secret|private key|BEGIN .*PRIVATE KEY|\\.env" <changed-paths>
```

검증을 실행하지 못하면 실행 불가 사유와 남은 리스크를 최종 보고에 적습니다.
