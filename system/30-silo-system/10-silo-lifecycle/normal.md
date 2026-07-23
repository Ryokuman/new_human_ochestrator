# 일반 사일로 생명주기

일반 사일로는 변경 diff, PR, patch, handoff가 주 산출물입니다.

생명주기는 `goal 전달 -> 구현/검증 -> 실패 시 원인 기록 또는 선택적 가설 체인 -> PR/patch/handoff -> 정리`를 중심으로 둡니다.

일반 사일로는 자동 삭제를 기본값으로 삼지 않습니다.

```text
1. 시작 gate: project 계층 작업 브랜치에서 2계층 `Project Work SSoT` 원본 task/issue 상태를 `in_progress`로 바꾸는 상태 갱신 PR을 만들고 머지를 확인한다. 1계층 `Project SSoT`는 해당 원문 위치를 찾기 위한 index나 project-level 계약 참조로만 사용한다. 목표 모델에서는 `project-{projectName}/{taskname}`와 `project-{projectName}/main`, 현재 호환 상태에서는 `project-{projectName}-{taskname}`와 `project-{projectName}`을 사용한다.
2. 준비: task a를 읽고 사일로 내부에 goal을 전달한다.
3. 구현/검증: task 계약에 맞춰 구현, 수정, 문서화, 검증을 수행한다.
4. 실패 기록: 실패하면 실행 로그, 실패 결과, 원인을 task-local evidence 또는 사일로 보고에 남긴다.
5. 선택적 가설 체인: 실패 원인과 다음 시도를 같은 task 안에서 추적해야 할 때만 `Hypothesis Chain`을 작성한다.
6. 재실행 또는 범위 조정: 다음 시도가 저위험이면 이어 실행하고, 공유 상태나 계약 변경이 필요하면 사용자 판단 필요로 보고한다.
7. 완료 또는 중단: 성공하면 PR/patch/handoff로 정리하고, 한계를 넘으면 사용자 판단 필요로 보고한다.
```

시작 gate는 준비 단계의 일부가 아닙니다. 상태 갱신 PR이 project 계층 메인 브랜치에 머지되기 전에는 사일로 root, `goal.md`, repo clone, 작업 브랜치를 만들지 않습니다. 상태 갱신 PR을 만들거나 머지 상태를 확인할 수 없으면 일반 사일로 실행을 계속하지 않고, 갱신 불가 사유와 사용자 판단 필요 여부를 보고합니다.

가설 체인은 일반 사일로의 필수 실행 루프가 아닙니다. 실패 분석과 다음 시도 근거가 필요한 task에서만 [`hypothesis-chain.md`](hypothesis-chain.md)를 참고합니다.

## 정리 전 확인

- PR이 있으면 PR URL, state, `mergedAt`, merge commit, PR head branch, PR head SHA, GitHub target/base branch를 재조회합니다.
- cleanup 가능 여부는 PR이 merged 상태인지, 로컬 브랜치 HEAD가 PR head SHA와 일치하는지, 해당 worktree가 clean인지, ahead commit이나 미고정 산출물이 남아 있지 않은지를 함께 확인한 뒤 판단합니다.
- patch 제출이면 patch가 어떤 branch/commit/PR과 대응되는지 확인합니다.
- 내부 repo와 사일로 루트의 미커밋 변경, untracked 파일, ahead commit, 원격 push 상태를 확인합니다.
- worktree가 연결되어 있으면 clean 상태와 연결 branch를 확인합니다.
- repair/conflict 사일로는 원 PR, 대체 PR, 또는 patch 동등성이 확인되기 전까지 삭제하지 않습니다.
- 정리 보고에는 `PR/patch`, `검증`, `merge/cleanup 상태`, `보존/삭제 후보`를 분리합니다.
