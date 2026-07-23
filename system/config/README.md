# Config 템플릿

`system/config/`는 공개 가능한 config example과 `setup.sh --init-config`가 같은 디렉토리에 생성하는 local config 초안을 둡니다. 현재 setup과 repo skill의 기본 실행 경로도 `system/config/` 아래 gitignore된 local 파일을 기준으로 합니다.

남기는 파일:

- `silo-runtime.env.example`
- `silo-projects.example.yaml`
- `silo-secrets.example.yaml`
- `shared-runtime-registry.example.yaml`
- `public-export-manifest.example.yaml`
- `public-export-guard-manifest.yaml`

`setup.sh --init-config`는 아래 파일을 `system/config/`에 생성합니다. 실제 값 파일은 git에 올리지 않으며, `system/.gitignore`가 이 경로를 제외합니다.

- `system/config/silo-runtime.env`
- `system/config/silo-projects.yaml`
- `system/config/silo-secrets.yaml`
- `system/config/shared-runtime-registry.yaml`
- `system/config/public-export-manifest.yaml`
- `system/config/*.local.yaml`

직접 추가하는 local 설정도 git에 올리지 않습니다.

- `system/config/*.env`
- `system/config/*.local.yaml`
- `system/config/shared-runtime-registry.yaml`
- `system/config/silo-projects.yaml`
- `system/config/silo-secrets.yaml`
- `system/config/public-export-manifest.yaml`

## 공개 export manifest와 guard 입력

`public-export-manifest.example.yaml`은 공개 export allowlist와 제외 정책을 설명하는 공개 가능한 예시/정책 템플릿입니다.

`public-export-guard-manifest.yaml`은 `.github/workflows/sync-public-orchestrator.yml`의 `Block internal project references` 단계가 읽는 비공개 실행 입력입니다. 내부 프로젝트명 regex는 이 파일에서 관리하고, 공개 배포 대상인 example manifest에는 내부 프로젝트명을 반복하지 않습니다.

루트 `config/`는 현재 기본 실행 경로가 아니지만, 수동 local override나 향후 전환 중 실제 값이 잘못 커밋되지 않도록 루트 `.gitignore`가 함께 보호합니다. 새 example을 추가해야 할 때는 `*.example.*` 또는 `*.env.example`처럼 공개 값만 담는 이름을 사용합니다.

세부 정책은 아래 문서를 기준으로 봅니다.

- 사일로 구조: `../30-silo-system/README.md`
- runtime set: `../30-silo-system/40-silo-runtime-set/README.md`
- Run Set: `../30-silo-system/40-silo-runtime-set/run-set.md`

## 공개 export manifest의 지위

`public-export-manifest.example.yaml`은 공개 export 정책을 설명하는 예시/정책 템플릿입니다. 현재 실행 workflow인 `.github/workflows/sync-public-orchestrator.yml`은 이 manifest의 `exclude.paths`를 읽어 공개 stage에서 제외할 경로를 제거하고, 같은 경로를 가리키는 README 인덱스 링크도 제거합니다. 공개 export allowlist, sensitive path guard, secret-like guard는 workflow run block에 적힌 명시적 기준을 실행 정본으로 사용합니다. 내부 프로젝트 참조 차단 regex는 `system/config/public-export-guard-manifest.yaml`을 실행 입력으로 읽습니다.

따라서 공개 export allowlist나 secret-like guard를 실제로 바꾸려면 workflow run block을 함께 수정해야 합니다. 공개 stage 제외 대상과 README 인덱스 링크 제거 기준을 바꾸려면 `public-export-manifest.example.yaml`의 `exclude.paths`를 수정합니다. 내부 프로젝트 참조 차단 regex를 바꾸려면 `public-export-guard-manifest.yaml`을 수정합니다.

## PR loop와 handoff에서 쓰는 config

사일로 PR 흐름은 config 유무에 따라 다르게 움직입니다.

```text
PR 생성
-> Codex review 설정 확인
-> 설정 있음: codex-pr-review-loop 실행
-> 명시적 설정 없음/권한 없음: review loop 생략, PR에 `Codex review 미설정` 기록
-> 실제 제품 코드와 runtime/E2E 확인이 있는 사일로 PR이면 silo-runtime-handoff가 runtime/E2E 가능 여부를 config 기준으로 판단
```

Codex review 설정은 이 디렉토리의 파일만으로 결정되지 않습니다. GitHub repo 또는 organization의 Codex review 호출 권한, GitHub App 설치, PR 댓글의 `@codex review` 응답 경로가 함께 필요합니다. 아직 확인 전이면 먼저 `@codex review`를 호출해 접수 여부를 확인하고, 설정 없음이나 권한 없음이 명시적으로 확인될 때만 `codex-pr-review-loop`를 억지로 돌리지 않고 PR 본문이나 보고에 `Codex review 미설정`을 남깁니다. 실제 제품 코드와 runtime/E2E 확인이 있는 사일로 PR만 runtime handoff로 넘깁니다.

## config 파일 역할

| 파일 | 역할 | PR/handoff 영향 |
|---|---|---|
| `system/config/silo-runtime.env` | 사일로 workspace root, project config 위치, 기본 보호 브랜치, 브랜치 prefix, 실행 모드를 지정합니다. | 사일로 디렉토리 생성 위치, repo clone 위치, 작업 브랜치 이름, yolo/test 실행 모드의 기본값을 정합니다. |
| `system/config/silo-projects.yaml` | project id, repo URL, 기본 브랜치, 보호 브랜치, silo 허용 여부, repo 역할, DB/schema 정본 위치, service policy를 지정합니다. | task 사일로가 어떤 repo를 clone하고 어떤 branch를 보호해야 하는지, shared BE/API 또는 service를 사일로가 직접 켤 수 있는지 판단합니다. |
| `system/config/shared-runtime-registry.yaml` | shared runtime set, runtime별 workspace, branch/commit, port, env policy, health check를 지정합니다. | PR handoff에서 Docker DB, shared BE/API, FE/harness, worker, mock service를 켤 수 있는지와 E2E 가능 여부를 판단합니다. |
| `system/config/public-export-manifest.yaml` | 공개 저장소로 내보낼 파일, 디렉토리, 경로 매핑, 제외 대상의 정책 초안을 기록합니다. | 현재 workflow는 example manifest의 `exclude.paths`를 공개 stage 제외와 README 링크 제거 기준으로 읽습니다. allowlist나 guard를 실제로 바꾸려면 `.github/workflows/sync-public-orchestrator.yml`의 run block 또는 `public-export-guard-manifest.yaml`을 함께 수정합니다. |
| `system/config/silo-secrets.yaml` | secret provider나 secret 주입 정책을 지정합니다. 실제 secret 값은 기록하지 않습니다. `silo-env-injection.example.yaml`은 provider 이름, env 파일 위치 정책, 필수 env key 이름처럼 공개 가능한 주입 계약만 예시로 둡니다. | secret 값 없이 env 주입 방식만 확인합니다. secret 값이 필요하면 handoff에 실행 불가 또는 사용자 확인 필요로 남깁니다. |

## E2E handoff 판단

`silo-runtime-handoff`는 E2E 가능 여부를 task 설명만으로 판단하지 않습니다. 아래 순서로 config를 확인합니다.

1. `silo-runtime.env`에서 `SILO_PROJECTS_CONFIG`, `SILO_WORK_ROOT`, `SILO_BRANCH_PREFIX`, `SILO_EXECUTION_MODE`를 확인합니다.
2. `silo-projects.yaml`에서 대상 project의 repo, protected branch, `allowed_for_silo`, DB/schema 정본 위치, service policy를 확인합니다.
3. `silo-secrets.yaml`이 있으면 secret 원문이 아니라 secret provider, env 파일 위치 정책, 필수 env key 이름 같은 주입 계약만 확인합니다.
4. `shared-runtime-registry.yaml`에서 필요한 `runtime_set`과 서버형 runtime의 health check를 확인합니다.
5. shared BE/API, DB, FE/harness, worker, mock service 중 task E2E에 필요한 runtime이 모두 켜져 있고 health check가 통과해야 E2E 가능으로 씁니다.
6. 일부 runtime이 없거나 실패하면 E2E 성공처럼 쓰지 않고, 실패 runtime, 실패 명령 또는 URL, 대체 증거, 남은 수동 확인을 PR 댓글에 남깁니다.
7. `runtime_set` 자체가 없으면 `add-shared-runtime` 또는 project runtime_set 정의가 먼저 필요하다고 보고합니다.

## 기록 금지

- secret, token, password, credential 실제 값
- production DB 접속 정보
- 개인 계정 세션 값
- 프로젝트별 private repo URL이 공개 문서에 노출되면 안 되는 경우의 원문 URL
