# Workspace Local 검수와 승인 후 승격

## 목적

보호된 계층 메인 브랜치를 직접 수정하지 않으면서 merge 전 Markdown 결과를 실제 Obsidian에서 검수합니다. 승인 전 초안은 Git 변경과 분리하고, 승인된 결과만 독립 worktree와 PR로 정식 SSoT에 승격합니다.

## 소유 계층과 비정본 선언

`<workspace>/local/<작업명>/`은 3계층 검수·evidence 공간입니다. 별도 Git 저장소를 만들지 않고 상위 repo에서 제외합니다. 사용자 승인을 받아도 PR이 merge되기 전까지 정식 SSoT가 아닙니다.

## 작업 시작 Preflight

작업 시작 전 현재 branch가 `{layerNamespace}/main`인지 확인합니다. 예시는 `main-v3/main`, `workspace-example/main`, `project-example/main`입니다. 계층 메인이 아니면 checkout이나 rebase하지 않고 사용자에게 메인이 아닌 이유를 질문하며 local 작성도 시작하지 않습니다. 사용자가 호환 `project-{projectName}` 또는 `project/<project-id>`를 계층 메인으로 확인한 경우에만 정확한 현재 브랜치명을 명시해 compatibility preflight를 실행합니다. 호환 project 작업 브랜치는 자동 허용하지 않습니다.

계층 메인이면 동일한 `<remote>/<현재 branch>`를 fetch합니다. worktree가 clean하고 local 고유 commit이 없으며 remote만 앞선 경우에만 `ff-only`로 최신화합니다. dirty, local ahead, diverged, remote 조회 실패는 자동 처리하지 않습니다. 통과한 remote, branch와 SHA를 검수 metadata에 기록합니다.

## Workspace 단일 Obsidian Vault

`<workspace>` 하나를 Obsidian vault로 등록합니다. 따라서 `local/`, `system/`, `projects/`, `task-*` 아래 Markdown은 vault를 추가하지 않고 열 수 있습니다. workspace 밖의 worktree는 포함되지 않으므로 승인 전 사용자 검수본은 항상 workspace 안의 `local/<작업명>/`에 둡니다.

`.git/`, secret·credential 디렉터리, `node_modules/`, `dist/`, `build/`, `coverage/`와 대용량 생성 cache는 Obsidian 탐색·검색 제외 대상으로 둡니다. `sources/`와 `shared-runtime/`은 문서를 포함할 수 있어 workspace별로 판단합니다. 제외 설정은 secret 보호 장치가 아니며 실제 secret 값은 Markdown에 기록하지 않습니다.

## Local 구조와 쓰기 경계

```text
local/<작업명>/
├── .writer-lease/
├── _review.md
├── metadata.yaml
└── evidence/
```

승인 전에는 현재 작업의 `local/<작업명>/` 안에서만 파일을 생성·수정합니다. `system/`, `projects/`, `user-layer/`, `task-*`, source repo와 다른 local 작업은 수정하지 않습니다. 기준선 fetch와 계층 메인의 `ff-only`, 별도 승인된 최초 vault 등록만 preflight/setup 예외입니다.

서로 다른 작업은 디렉터리 단위로 병렬 작성할 수 있습니다. 같은 작업의 writer는 하나만 허용합니다. session 고유 writer ID로 `.writer-lease/` 디렉터리를 원자적으로 생성한 세션만 쓸 수 있으며, 매 수정 전 소유권 확인과 장기 작업 중 갱신을 수행합니다. 충돌·소유권 불일치·lease 없음은 쓰기 중단 조건입니다. lease는 같은 소유자만 완료·handoff 때 해제하고, 중단된 lease는 자동 만료나 강제 삭제하지 않습니다. lease, revision과 content hash로 검수 중인 내용을 고정합니다.

## 사용자 링크 계약

사용자 확인이 필요한 Markdown은 파일 경로만 전달하지 않습니다. 절대경로 기반 `obsidian://open?path=...`를 만들고 전체 URI를 Base64로 인코딩해 아래 VS Code handler 링크로 전달합니다.

```text
vscode://StefanSteinert.vscode-obsidian-links/open?href_b64=<Base64 Obsidian URI>
```

전달할 때는 설치된 `workspace-local-review` 스킬의 helper 절대경로, `--workspace-root <workspace 절대경로>`와 Markdown 절대경로를 사용합니다. 전달 전 파일 존재, workspace vault 내부 경로, 확장 설치와 URI round-trip을 확인합니다.

## 승인과 Worktree 승격

승인은 `work_id`, revision, content hash, base remote/branch/SHA에 연결합니다. 승인 뒤 내용이 달라지면 재검수합니다.

승인 후에만 worktree와 작업 브랜치를 만들 수 있습니다. 승인본의 base branch가 checkout된 workspace에서 처음과 동일한 preflight를 다시 실행해 remote 대비 ahead 0 / behind 0과 `ff-only` 최신화를 확인합니다. base drift가 승인 의미에 영향을 주면 승격하지 않고 최신 기준으로 검수본을 다시 합성합니다. `using-git-worktrees`를 사용할 수 있으면 그 안전 절차를 적용하고, 기본 설치에 해당 스킬이 없으면 preflight를 통과한 계층 메인·승인 revision/hash를 재확인한 뒤 native `git worktree add -b <계층 작업 브랜치> <worktree 경로> <계층 메인 브랜치>`를 대체 절차로 사용합니다. 기존 브랜치나 worktree는 덮어쓰지 않습니다. worktree가 생성된 뒤에만 승인 범위의 정식 문서를 수정합니다.

```text
local 승인
→ worktree·작업 브랜치 생성
→ 정식 경로 반영·검증
→ commit·push·PR·review
→ 별도 명시적 merge 승인
→ merge 확인
```

PR 생성 승인은 merge 승인으로 해석하지 않습니다. local의 다른 작업, evidence, `.obsidian` 개인 설정과 metadata는 PR에 포함하지 않습니다.

## Merge 후 대응 관계

merge 후 metadata에 정식 파일, 작업 브랜치, PR, merge commit과 승인 revision/hash를 기록합니다. local 검수본은 자동 삭제하지 않으며 삭제는 별도 정리 승인 또는 보존 정책을 따릅니다.

## 오류 처리

| 상황 | 처리 |
| --- | --- |
| 계층 메인이 아님 | 이유 질문 전 작성 중단 |
| main worktree dirty | 기존 변경 소유권 확인 |
| remote 없음·local ahead·diverged | 자동 최신화 중단 |
| 검토 중 새 요청 | 현재 revision 고정, 다음 revision 후보로 보존 |
| 승인 후 hash 변경 | 승인 무효화와 재검수 |
| 승인 후 의미 있는 base drift | 최신 기준으로 재합성 |
| worktree·PR 실패 | local 승인본 보존, 정본으로 표시하지 않음 |
| merge 승인 없음 | PR 상태만 보고하고 merge하지 않음 |

## 검증 기준

- 계층 메인이 아니면 local 디렉터리도 만들지 않습니다.
- remote만 앞선 clean main은 `ff-only` 뒤 ahead 0 / behind 0입니다.
- 승인 전 정식 문서 Git diff와 새 worktree가 없습니다.
- 검수 Markdown 링크가 VS Code에서 대상 Obsidian 문서를 엽니다.
- 승인한 revision/hash와 PR diff의 대응 관계를 추적합니다.
- local과 `.obsidian` 개인 설정은 PR에 포함되지 않습니다.
