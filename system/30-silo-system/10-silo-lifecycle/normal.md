# 일반 사일로 생명주기

일반 사일로는 변경 diff, PR, patch, handoff가 주 산출물입니다.

생명주기는 `goal 전달 -> 가설 실행 -> 실패/원인 기록 -> 다음 가설 또는 PR -> 정리`를 중심으로 둡니다.

일반 사일로는 자동 삭제를 기본값으로 삼지 않습니다.

```text
1. 준비: task a를 읽고 사일로 내부에 goal을 전달한다.
2. 가설 실행: 가설 a'를 세우고 구현/검증을 수행한다.
3. 실패 기록: a'가 실패하면 task a 내부에 a', 실행 로그, 실패 결과를 기록한다.
4. 원인 파악: 실패 원인을 task a 내부에 남긴다.
5. 다음 가설 작성: 같은 task a 내부에 가설 a''를 새로 세운다.
6. 재실행: a'' 실행 로그와 검증 결과를 task a 내부에 이어 기록한다.
7. 완료 또는 중단: 성공하면 PR/patch/handoff로 정리하고, 한계를 넘으면 사용자 판단 필요로 보고한다.
```

가설 체인 상세는 [`hypothesis-chain.md`](hypothesis-chain.md)를 기준으로 봅니다.

## 정리 전 확인

- PR이 있으면 PR URL, state, merge 상태, merge commit, head branch를 확인합니다.
- patch 제출이면 patch가 어떤 branch/commit/PR과 대응되는지 확인합니다.
- 내부 repo와 사일로 루트의 미커밋 변경, untracked 파일, ahead commit, 원격 push 상태를 확인합니다.
- worktree가 연결되어 있으면 clean 상태와 연결 branch를 확인합니다.
- repair/conflict 사일로는 원 PR, 대체 PR, 또는 patch 동등성이 확인되기 전까지 삭제하지 않습니다.
- 정리 보고에는 `PR/patch`, `검증`, `merge/cleanup 상태`, `보존/삭제 후보`를 분리합니다.
