# main-v2 repo-local Codex setup

이 디렉터리는 `main-v2`와 `main-v2`에서 파생된 브랜치에서만 Ponytail Codex plugin을 쓰기 위한 wrapper 전용 repo-local `CODEX_HOME`입니다.

글로벌 `~/.codex`에 Ponytail을 설치하지 않고, 프로젝트 자동 config 경로인 `.codex/config.toml`도 만들지 않습니다. 이 레포에서 Ponytail을 켜려면 아래 wrapper로 Codex를 실행합니다.

```bash
.codex-main-v2/bin/codex-main-v2
```

wrapper는 `CODEX_HOME`을 이 디렉터리로 지정하고, 실행 전 `.codex-main-v2/hooks/ponytail-branch-guard.sh`를 호출합니다. 일반 `codex` 실행은 이 디렉터리를 자동으로 쓰지 않으므로 Ponytail plugin enablement가 wrapper 밖으로 새지 않습니다.

새 checkout처럼 `.codex-main-v2/.tmp/`와 `.codex-main-v2/plugins/cache/`가 비어 있으면 wrapper가 `.codex-main-v2/bin/bootstrap-ponytail`을 먼저 실행합니다. bootstrap은 repo-local `CODEX_HOME`에만 아래 설치 입력을 적용합니다.

```bash
codex plugin marketplace add DietrichGebert/ponytail --ref v4.7.0
codex plugin add ponytail@ponytail
```

`.codex-main-v2/.tmp/`와 `.codex-main-v2/plugins/cache/`는 재생성 가능한 산출물이므로 git에 추적하지 않습니다. 추적 대상은 wrapper, guard, config, bootstrap처럼 새 checkout에서 같은 상태를 재생성하는 입력 파일입니다.

guard 통과 조건은 아래와 같습니다.

- 현재 브랜치가 `main-v2`
- 현재 `HEAD`가 최신 `main-v2` 또는 선택된 원격의 `main-v2`를 포함함
- 오래된 `main-v2` 파생 브랜치처럼 `HEAD`와 `main-v2`의 공통 base가 저장된 legacy fork point와 다르고, legacy `main` 이력에 포함되지 않음

`main`과 `develop`은 lineage 계산 전에 명시적으로 차단합니다. Guard는 현재 브랜치의 upstream remote를 우선 사용하고, 없으면 `origin`, 그마저 없으면 첫 번째 remote를 사용합니다. Guard는 stale local `main-v2`/`main` ref보다 갱신한 `<remote>/main-v2`와 `<remote>/main`을 우선합니다. `main-v2` ref가 없는 single-branch checkout에서는 guard가 현재 브랜치 이력을 deepen/unshallow 한 뒤 선택된 원격의 `main-v2`를 `refs/remotes/<remote>/main-v2`로 가져와 판정합니다. `main`/`<remote>/main` ref는 `main` 기반 임시 브랜치를 차단하는 negative guard로만 준비합니다.

조건을 만족하지 않으면 Ponytail 관련 hook과 wrapper 실행은 중단됩니다.
