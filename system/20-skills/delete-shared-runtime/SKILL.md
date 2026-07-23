---
name: delete-shared-runtime
description: 프로젝트별 shared runtime registry/status 정리, archived 표시, 공용 runtime checkout 삭제 후보 검토 또는 명시 승인된 shared runtime 제거를 처리할 때 사용합니다.
---

# Delete Shared Runtime

이 스킬은 여러 task silo가 참조할 수 있는 shared runtime을 안전하게 제거하거나 archive 상태로 전환합니다.

## 적용 시점

아래 요청이 나오면 이 스킬을 사용합니다.

- shared runtime 삭제
- 공용 runtime 정리
- 오래된 runtime set archived 처리
- workspace root 아래 `shared-runtime/<runtime-name>/` 제거
- runtime registry/status에서 더 이상 쓰지 않는 항목 정리

## 원칙

- registry/status 정리와 실제 디렉터리 삭제는 분리합니다.
- destructive 삭제는 사용자 명시 요청 또는 승인된 작업 범위가 있을 때만 수행합니다.
- 참조 중인 task, agent, server, process, port, PR, handoff가 있으면 삭제하지 않고 보존 또는 archived 후보로 보고합니다.
- secret, token, password, credential 값은 읽거나 기록하지 않습니다.
- project registry/config, 2계층 Project Work SSoT runbook/status, local config에 있는 실제 runtime 구성값을 root `main-v3/main`에 복사하지 않습니다.

## 절차

1. 계층을 판정합니다. 공통 삭제 정책 변경이면 `main-branch-update-flow`, 특정 프로젝트 runtime 정리면 project registry/config 또는 2계층 Project Work SSoT의 runbook/status에서 처리합니다.
2. 삭제 대상 `project_id`, `runtime_name`, workspace path, registry/status 위치를 확인합니다.
3. 참조 상태를 확인합니다.
   - registry/status의 `linked_tasks`
   - 열린 task silo의 `goal.md`
   - 열린 PR과 handoff
   - 실행 중인 agent/server/process
   - 사용 중인 port
   - checkout dirty state와 unpushed commit
4. 참조가 있거나 dirty state, ahead commit, 실행 중 server가 있으면 삭제하지 않습니다. `보존`, `archived 후보`, `사용자 판단 필요`로 보고합니다.
5. 참조가 없고 삭제 범위가 명시되어 있으면 registry/status에서 제거하거나 `status: archived`로 바꿉니다.
6. 실제 디렉터리 제거가 필요하면 삭제 전 제거 대상 경로, git 상태, 보존할 로그/검증 결과 여부를 보고합니다.
7. 명시 삭제 승인 또는 이미 승인된 작업 범위가 확인된 경우에만 디렉터리를 제거합니다.
8. 제거 후 registry/status, 남은 workspace path, 실행 중 process 없음, 참조 없음, git 상태를 재확인합니다.
9. 완료 보고는 `삭제됨`, `보존`, `archived`, `위험`, `후속 후보`로 분리합니다.

## 삭제 전 확인 명령 후보

프로젝트별 도구가 있으면 2계층 Project Work SSoT의 runbook을 우선합니다. 일반 후보는 아래와 같습니다.

```bash
git -C shared-runtime/<runtime-name> status --short --branch
git -C shared-runtime/<runtime-name> log --oneline --max-count=5
rg -n "<runtime-name>|shared-runtime/<runtime-name>|shared-runtime/<project-id>/<runtime-name>" silos system/config
lsof -i :<port>
```

`lsof` 결과나 process 상세에 secret 값이 섞일 수 있으면 필요한 최소 정보만 보고합니다.

## registry/status 처리

삭제가 확실하지 않으면 즉시 제거하지 말고 archive 상태로 둡니다.

```yaml
status: archived
archived_at: YYYY-MM-DD
archive_reason: <why>
delete_after: <optional date or condition>
```

완전 삭제 후에도 프로젝트 운영상 추적이 필요하면 2계층 Project Work SSoT의 handoff나 runbook에 삭제 사실과 근거를 남깁니다.

## 금지

- 참조 중인 task silo가 있는데 디렉터리를 삭제하지 않습니다.
- dirty state, ahead commit, 미확인 local patch가 있는 checkout을 삭제하지 않습니다.
- 열린 PR head나 review 중인 branch에 연결된 runtime checkout을 삭제하지 않습니다.
- secret 파일 내용 확인을 삭제 조건으로 삼지 않습니다.
- root `main-v3/main`에 프로젝트별 실제 runtime registry 원문을 복사하지 않습니다.

## 보고 형식

```text
삭제됨:
- <runtime>: <registry/status 변경>, <directory removal>

보존:
- <runtime>: <이유>

archived:
- <runtime>: <archive 위치와 이유>

위험:
- <runtime>: <dirty/ahead/reference/process/port 등>

후속 후보:
- <별도 task/PR/사용자 확인 필요 항목>
```
