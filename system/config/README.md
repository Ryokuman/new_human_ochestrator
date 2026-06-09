# 사일로 런타임 설정

이 폴더는 여러 프로젝트에서 공통 프롬프트를 재사용하기 위해 필요한 설정 템플릿을 둡니다.

git에 포함하는 파일:

- `silo-runtime.env.example`
- `silo-projects.example.yaml`

git에 포함하지 않는 파일:

- `silo-runtime.env`
- `silo-projects.yaml`
- `silo-secrets.yaml`
- `*.local.yaml`

## 사용 방식

프로젝트별 실제 값은 아래 둘 중 하나로 주입합니다.

1. `system/config/silo-runtime.env`
2. `system/config/silo-projects.yaml`

시크릿 저장소를 따로 쓰는 환경이면 같은 내용을 secret manager, vault, 1Password, Doppler, AWS Secrets Manager, GitHub Actions secrets 등에 넣어도 됩니다.

중요한 기준:

- 공통 프롬프트에는 프로젝트명, 레포 URL, 보호 브랜치 이름, 계정, 토큰을 박지 않습니다.
- 사일로 생성 시 메인 오케스트레이터가 이 설정을 읽어 clone 대상과 보호 브랜치를 결정합니다.
- 보호 브랜치 정보는 시크릿은 아니어도 프로젝트 의존 값이므로 gitignore된 로컬 설정으로 둡니다.

## 공용 백엔드와 사일로 대상

사일로가 직접 clone해서 고치는 프로젝트와, 메인 오케스트레이터가 세션 동안 하나만 띄워두는 공용 서비스를 분리합니다.

예:

- 사일로 대상: page generator, test harness
- 공용 서비스: backend

공용 서비스는 `allowed_for_silo: false`로 두고 `service_policy.owner: main-orchestrator`로 표시합니다.

사일로가 공용 서비스 수정 필요성을 발견하면 바로 수정하지 않고 PR description의 `SSoT 승격 후보` 또는 `메인 오케스트레이터 판단 필요`에 올립니다.

## YOLO 모드

기본 실행 모드는 `yolo`입니다.

의미:

- 사일로는 필요한 레포지토리만 새로 clone합니다.
- 사일로는 보호 브랜치가 아닌 새 작업 브랜치를 만듭니다.
- 격리 clone과 작업 브랜치 안에서는 source code, generated output, test, tooling을 승인 없이 자유롭게 수정할 수 있습니다.
- 실패하면 clone/branch를 폐기할 수 있습니다.
- 결과는 PR로 제출합니다.

YOLO 모드에서도 풀리지 않는 금지선:

- 보호 브랜치 직접 commit/push 금지
- production 데이터 쓰기 금지
- secret 값 로그/문서 기록 금지
- 공유 브랜치 force push 금지
