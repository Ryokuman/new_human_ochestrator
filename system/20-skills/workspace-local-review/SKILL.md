---
name: workspace-local-review
description: 작업 시작 전 계층 메인과 동일 remote branch를 최신화하고, 승인 전 문서를 workspace의 local/<작업명>/에서만 작성해 Obsidian 링크로 검수받은 뒤 승인 후에만 독립 worktree·작업 브랜치·PR로 승격할 때 사용합니다.
---

# Workspace Local 검수와 승인 후 승격

## 사용 원칙

- `<workspace>`는 하나의 Obsidian vault이고 `local/<작업명>/`은 Git 비추적 검수 공간입니다.
- 각 작업 디렉터리에 별도 `.git/`이나 vault를 만들지 않습니다.
- local 검수본은 PR이 merge되기 전까지 정식 SSoT가 아닙니다.

## 실행 순서

1. 현재 브랜치가 계층 메인인지 확인합니다.
2. 현재 브랜치가 계층 메인 브랜치가 아니면 사용자에게 메인이 아닌 이유를 질문하고 local 디렉터리도 만들지 않습니다. 사용자가 호환 `project-{projectName}` 또는 `project/<project-id>`를 계층 메인으로 확인한 경우에만 정확한 현재 브랜치명을 `--compatible-main <branch>`로 전달합니다.
3. 일반 계층 메인은 `scripts/preflight.sh <remote>`, 사용자 확인을 거친 호환 project 메인은 `scripts/preflight.sh --compatible-main <branch> <remote>`를 실행합니다.
4. 통과한 remote, branch와 SHA를 metadata에 기록합니다.
5. session 고유 `writer_id`를 만들고 `bash "<설치된 workspace-local-review 스킬 절대경로>/scripts/writer-lease.sh" acquire "<local 작업 절대경로>" "<writer_id>"`로 원자적 lease를 획득합니다. exit `31` 충돌이면 쓰기를 시작하지 않습니다. 획득 후에만 `assets/`의 검수본과 metadata 양식을 `local/<작업명>/`에 복사해 실제 값을 채웁니다.
6. 승인 전에는 현재 작업의 local 디렉터리만 수정합니다. local/ 밖의 정식 문서를 수정하지 않습니다.
7. Markdown마다 `ruby "<설치된 workspace-local-review 스킬 절대경로>/scripts/generate-obsidian-link.rb" --workspace-root "<workspace 절대경로>" "<Markdown 절대경로>"`로 링크를 만들고 사용자에게 전달합니다. 현재 작업 디렉터리, helper 파일의 실행 권한이나 repo checkout 위치에 의존하지 않습니다.
8. 검수본 revision과 SHA-256 hash를 metadata에 기록해 승인받습니다.
9. 승인 후에만 아래 `승격 worktree 도구 확인`에 따라 계층 메인에서 독립 worktree와 작업 브랜치를 만듭니다.
10. 승인된 범위만 정식 경로에 반영하고 계층별 검증과 scope gate를 통과합니다.
11. commit, push, PR과 review loop를 진행합니다.
12. PR merge는 별도 명시 승인을 받은 뒤에만 수행합니다.
13. merge 후 PR, merge commit, 정식 경로와 승인 revision/hash를 local metadata에 기록합니다.

## Preflight 결과 처리

| exit | 의미 | 처리 |
| --- | --- | --- |
| `20` | non-main branch | 메인이 아닌 이유를 사용자에게 질문 |
| `21` | dirty main | 기존 변경 소유권과 처리 방향 확인 |
| `22` | remote ref 없음 | 기준 SHA를 확정하지 않고 중단 |
| `23` | local main ahead | 보호 브랜치 로컬 고유 commit 조사 |
| `24` | diverged | 자동 merge/rebase 금지 |

remote만 앞선 clean main은 helper가 `ff-only`로 최신화하고 ahead 0 / behind 0을 확인합니다.

호환 `project-{projectName}`와 `project/<project-id>` 메인은 작업 브랜치와 이름만으로 완전히 구분할 수 없으므로 자동 허용하지 않습니다. 사용자가 해당 브랜치를 계층 메인으로 확인한 뒤에만 `--compatible-main`에 정확한 현재 브랜치명을 넘깁니다.

## 승격 worktree 도구 확인

승인 후 worktree를 만들기 전에 승인본의 base branch가 checkout된 workspace에서 처음과 동일한 preflight를 다시 실행합니다. 일반 계층 메인은 `scripts/preflight.sh <remote>`, 사용자 확인을 거친 호환 project 메인은 `scripts/preflight.sh --compatible-main <branch> <remote>`를 실행해 remote 대비 ahead 0 / behind 0과 `ff-only` 최신화를 확인합니다. 새 `BASE_SHA`가 승인 당시 SHA와 달라 승인 의미에 영향을 주면 worktree를 만들지 않고 검수본을 다시 합성합니다. 그 다음 현재 세션에서 `using-git-worktrees`를 사용할 수 있는지 확인합니다.

- 사용할 수 있으면 해당 스킬의 격리·안전 확인 절차를 적용합니다.
- 기본 `--repo-skills` 또는 `--quickstart` 설치처럼 해당 스킬이 없으면 중단하지 않고 native Git 대체 절차를 사용합니다. 재실행한 preflight가 통과한 계층 메인과 승인 revision/hash를 다시 확인한 뒤 `git worktree add -b <계층 작업 브랜치> <worktree 경로> <계층 메인 브랜치>`로 독립 worktree를 만듭니다.
- 이미 존재하는 브랜치나 worktree를 덮어쓰지 않으며, 생성에 실패하면 현재 workspace에서 정식 문서를 대신 수정하지 않습니다.

## 병렬 작성

서로 다른 작업은 다른 `local/<작업명>/`에서 병렬 작성합니다. 같은 작업은 하나의 writer lease만 허용합니다.

- writer는 세션마다 충돌하지 않는 `writer_id`를 만들고 작업 디렉터리에 `.writer-lease/`를 원자적으로 생성합니다. `metadata.yaml`에 writer와 lease 획득·갱신 시각을 기록합니다.
- 파일을 수정하기 전마다 설치된 helper 절대경로로 `writer-lease.sh check`, 장기 작업 중에는 `writer-lease.sh renew`를 실행해 같은 소유자인지 확인합니다. exit `31`은 기존 writer 충돌, `32`는 소유권 불일치, `33`은 lease 없음이며 모두 쓰기 중단 조건입니다.
- 완료·명시적 handoff 때만 같은 소유자가 설치된 helper 절대경로로 `writer-lease.sh release`를 실행하고 `lease_released_at`을 기록합니다. 중단된 lease는 자동 만료·강제 삭제하지 않고 사용자 확인 뒤 원 소유자 복구 또는 별도 정리를 결정합니다.
- 검토 중 revision을 자동 변경하지 않습니다. 새 요청은 evidence로 보존하고 다음 revision에서 합성합니다.

## Obsidian 링크

직접 전달 형식은 아래와 같습니다.

```text
vscode://StefanSteinert.vscode-obsidian-links/open?href_b64=<Base64 Obsidian URI>
```

현재 로드한 `SKILL.md`가 들어 있는 디렉터리를 설치된 스킬 절대경로로 사용하고, vault로 등록한 workspace와 검수 Markdown도 각각 절대경로로 전달합니다. 파일 존재, workspace 내부 경로와 URI round-trip을 helper로 검증합니다. helper는 VS Code CLI 또는 로컬 extension 디렉터리에서 `StefanSteinert.vscode-obsidian-links` 설치를 확인하고, 없으면 링크를 출력하지 않은 채 설치 필요를 보고합니다.

## 금지선

- non-main에서 이유 확인 없이 시작
- 승인 전 local 밖 작성, 자동 포맷과 상태 갱신
- 승인 전 worktree·작업 브랜치 생성
- local 원문이나 `.obsidian` 개인 설정을 PR에 포함
- PR 생성 승인을 merge 승인으로 확대
- secret, credential과 production 데이터를 Markdown에 기록

## 완료 보고

사용한 스킬, 현재 대화 workspace와 승격 worktree, 기준 SHA, 검수 링크, 승인 revision/hash, PR과 review 상태, merge 미수행 여부를 보고합니다.
