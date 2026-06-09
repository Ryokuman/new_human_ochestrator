# 개인 프로필

이 폴더는 공통 프롬프트가 읽을 사용자 개인 프로필 템플릿을 둡니다.

git에 포함하는 파일:

- `personal-profile.example.md`

git에 포함하지 않는 파일:

- `personal-profile.local.md`
- `personal-profile.md`
- `user-profile.md`
- `personality.md`

## 원칙

- 공통 프롬프트에는 개인 정보, 프로젝트 의존 정보, secret 위치를 직접 박지 않습니다.
- 실제 사용자 정보는 gitignore된 로컬 프로필에 둡니다.
- 모르는 항목은 `미입력`으로 남깁니다.
- 에이전트는 `미입력` 항목을 추론으로 채우지 않습니다.
- 사용자의 대화나 PR 피드백으로 새 정보가 명확해질 때만 갱신합니다.
