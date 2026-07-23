# 머지 승인과 보고

## 머지 승인 기준

PR 생성과 PR 머지는 별도 승인 단위입니다.

에이전트는 사용자가 아래처럼 머지를 명시한 경우에만 PR을 머지합니다.

- `approve`
- `LGTM`
- `머지하세요`
- `머지해도 됩니다`
- `1. 머지`

아래 표현은 작업 진행 또는 PR 생성 승인일 수 있지만, 머지 승인으로 해석하지 않습니다.

- `진행해`
- `작업 이어가`
- `PR 만들어`
- `main-v3/main 업데이트`
- `1. 승인`

## 머지 시 재조회

PR이 머지될 때 메인 오케스트레이터는 즉시 아래를 재조회합니다.

- `state`
- `mergedAt`
- `mergeCommit`
- PR head SHA
- GitHub PR target/base branch
- PR head branch
- 로컬 worktree clean 여부
- upstream 대비 ahead 없음 여부

## 보고 형식

```text
머지 결과:
- 머지된 PR:
- state:
- mergedAt:
- mergeCommit:
- PR head SHA:
- GitHub PR target/base branch:
- PR head branch:
- 로컬 worktree clean:
- upstream 대비 ahead 없음:
- 해결된 SSoT issue/task:
- 새로 승격된 issue/task:
- 승격하지 않은 로컬 발견:
- 이유:
- 사용자 피드백 반영:
- 다음 사일로 후보:
```
