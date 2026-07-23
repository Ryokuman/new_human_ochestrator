# 스프린트 병렬 mock 계약 가설

## ID

OH-0003

## 상태

draft

## 기간

- 시작: 2026-07-02
- 종료 또는 폐기:

## 운영 가설

프로젝트 contract가 기능 slice를 나눌 만큼 성숙했지만 실제 service/API 구현 순서가 병목일 때, 스프린트를 기능 slice 단위로 나누고 각 slice가 mock, stub, API 계약을 명시적으로 사용하게 하면 여러 작업자가 병렬로 첫 결과물을 만들 수 있다.

반대로 project contract가 제품 정의, 목표/비목표, 핵심 사용자 흐름, 데이터 경계, repo/service 역할을 설명하지 못하는 상태라면 이 가설을 적용하지 않는다. 그 경우에는 기존 project contract gate를 먼저 수행하고, mock/stub 병렬 작업을 열지 않는다.

단, mock과 stub은 최종 구현물이 아니라 스프린트 내부 검증 장치로만 취급한다. 스프린트 종료 시점에는 mock 제거, 실제 service 연결, API 계약 차이 정리, 버전 업, 최종 머지 gate를 별도로 두어 병렬 작업의 임시 계약이 제품 정본으로 굳는 것을 막는다.

## 채택 이유

project contract gate 대화에서 반복적으로 드러난 병목은 기능을 순차적으로 완성하려 하면 첫 화면, API, DB, service 연결 중 하나가 막히는 순간 나머지 작업도 대기한다는 점이었다. 반대로 모든 계약을 먼저 완벽히 설계하려 하면 Build -> Learn -> Spec 흐름이 느려지고, 아직 검증되지 않은 상세 설계가 task에 과하게 들어간다.

스프린트 단위로 병렬 slice를 정의하고 mock/stub/API 계약을 임시 실행 계약으로 고정하면, 각 작업자는 실제 service 완성 전에도 화면 흐름, 상태 변화, validation, 에러 처리, API 소비 형태를 검증할 수 있다. 이후 스프린트 종료 gate에서 mock 제거와 실제 service 연결을 한 번 더 확인하면, 빠른 병렬 구현과 정본 계약 정리를 분리할 수 있다.

## 취합한 정보

- project contract gate 대화에서 기능 요구사항을 바로 task로 쪼개기보다, 먼저 스프린트 목표와 slice 경계를 잡아야 병렬 작업 범위를 설명하기 쉬웠다.
- 실제 service/API가 아직 없거나 미성숙한 경우에도, mock/stub/API 계약을 명시하면 FE, BE, harness, QA가 서로 기다리지 않고 관찰 가능한 산출물을 만들 수 있다.
- mock/stub을 임시 장치로 명시하지 않으면, 스프린트가 끝난 뒤에도 임시 데이터, fake service, 하드코딩된 응답이 남을 위험이 있다.
- 여러 slice가 병렬로 진행되면 개별 PR은 통과해도 최종 버전 업, 통합 service 연결, 최종 머지 순서가 별도 gate로 관리되지 않으면 누락된다.
- 특정 프로젝트 내부 요구사항 원문은 0계층에 둘 대상이 아니며, 반복 가능한 운영 방식만 운영 가설로 승격해야 한다.

## 기존 방식의 문제

- 기능 task를 개별 단위로만 보면 sibling task가 어떤 mock 계약을 공유하는지, 어떤 실제 service 연결을 기다리는지 드러나지 않았다.
- API가 없다는 사실을 단순 blocker로 보면 프론트 작업이 멈추고, 반대로 임의 mock을 허용하면 나중에 실제 service와 맞지 않는 UI/상태 계약이 생겼다.
- task별 mock 데이터와 스프린트 종료 시 제거해야 할 mock/stub 목록이 분리되지 않아 임시 구현이 정본처럼 남을 수 있었다.
- 병렬 task의 결과를 바로 최종 머지 후보로 보면, 버전 단위 통합 확인과 실제 service 연결 확인이 누락될 수 있었다.
- project contract가 부족한 상태에서 각 task가 필요한 API, DB, service 역할을 제각각 추정하면 통합 시점에 계약 충돌이 커졌다.

## 예상 병목

- mock/stub 계약을 너무 느슨하게 쓰면 실제 service 연결 시 필드명, error shape, 상태 전이, auth/session 전제가 달라질 수 있다.
- mock 제거 gate가 없으면 스프린트 종료 후에도 fake service, fixture, 임시 branch flag가 남을 수 있다.
- 실제 service 연결을 한 task에 몰아넣으면 병렬 개발로 줄인 시간이 통합 gate에서 다시 병목이 될 수 있다.
- 버전 업 기준이 없으면 어떤 slice가 이번 버전에 들어가고 어떤 slice가 다음 버전으로 넘어가는지 불명확해진다.
- 최종 머지 직전에 project SSoT, task 결과, PR 본문, runtime evidence가 서로 다른 상태를 가리킬 수 있다.

## 적용한 작업 방식

- 스프린트 시작 전에 project contract에서 이번 버전 목표, 비목표, 핵심 사용자 흐름, 데이터 경계, 실제 service/API 정본 위치, mock 허용 범위를 확인한다. 이 확인이 실패하면 스프린트 병렬 mock 작업을 시작하지 않고 project contract 보강으로 되돌린다.
- 스프린트는 사용자 목적 기준의 기능 slice로 나누고, 각 slice는 독립적으로 관찰 가능한 output과 acceptance를 가진다.
- 병렬 task는 sibling task 완료를 전제로 삼지 않는다. sibling 완료가 필요한 최종 통합 E2E는 스프린트 종료 gate 또는 별도 integration task로 분리한다.
- mock/stub/API 계약은 task 본문 또는 `goal.md`에 명시한다. 최소한 목적, mock 데이터 출처, 응답 shape, 실제 service 연결 예정 위치, 제거 조건을 적는다.
- 실제 API가 없을 때는 임시 endpoint나 client adapter를 만들 수 있지만, 정본 API로 확정하지 않고 `스프린트 임시 계약`으로 표시한다.
- 스프린트 종료 시에는 mock/stub 제거 대조표를 작성한다. 각 항목을 `제거 완료`, `실제 service 연결 완료`, `다음 버전까지 유지`, `폐기 후보`, `사용자 판단 필요`로 분류한다.
- 버전 업 전에 이번 스프린트의 slice별 PR, mock 제거 상태, 실제 service 연결 상태, 남은 QA, project SSoT 갱신 필요 항목을 한곳에 모은다.
- 최종 머지는 개별 task no-major만으로 판단하지 않고, 버전 단위 통합 상태와 mock 제거 대조표를 함께 확인한다.

## 적용 범위

- 여러 기능 slice를 병렬로 진행하는 스프린트
- project contract는 성숙했지만 실제 service/API/DB 구현이 아직 완성되지 않아 UI, 상태 흐름, API 소비 형태를 먼저 검증해야 하는 task
- sibling task 간 의존이 있는 프로젝트 작업
- 스프린트 종료 시 버전 업, 통합 QA, 최종 머지 판단이 필요한 작업

적용하지 않는 범위:

- 단일 문서 수정이나 단일 repo skill 수정처럼 mock/stub 계약이 없는 작업
- project contract가 미성숙해 제품 정의, 핵심 사용자 흐름, 데이터 경계, repo/service 역할을 아직 설명하지 못하는 작업
- 이미 실제 service/API 계약이 안정되어 있고 병렬 task 간 임시 계약이 필요 없는 좁은 수정
- secret, credential, production 데이터, destructive action, 보호 브랜치 직접 수정이 필요한 작업

## 실행 결과

아직 실행 전이다. 이 문서는 project contract gate 대화에서 나온 반복 가능한 운영 방식을 0계층 가설로 초안화한 상태다.

## 실제 병목

아직 실행 전이라 실제 병목은 확인되지 않았다.

확인해야 할 후보:

- mock/stub 제거 대조표 작성 비용이 스프린트 속도를 과하게 늦추는지
- 각 task가 mock 계약을 충분히 작게 유지하는지
- 실제 service 연결 task가 스프린트 말미에 과도하게 커지는지
- 버전 업 기준이 project SSoT와 PR 본문에 같은 의미로 기록되는지

## 사람 확인 지점

- 이번 스프린트에서 mock/stub을 허용할 slice와 허용하지 않을 slice를 확인해야 한다.
- mock/stub이 사용자 확인용 임시 장치인지, 다음 버전까지 유지할 개발 fixture인지 구분해야 한다.
- 실제 service 연결 완료의 증거가 무엇인지 확인해야 한다.
- 이번 버전으로 올릴 slice와 다음 버전으로 넘길 slice를 확인해야 한다.
- 최종 머지 전에 mock 제거 대조표의 `다음 버전까지 유지`, `사용자 판단 필요` 항목을 승인받아야 한다.

## 유지할 것

- 스프린트를 사용자 목적 기준의 병렬 slice로 나누는 방식
- mock/stub/API 계약을 task별 임시 실행 계약으로 명시하는 방식
- sibling task 완료를 개별 task acceptance 전제로 두지 않는 방식
- 스프린트 종료 시 mock 제거와 실제 service 연결을 별도 gate로 확인하는 방식
- 버전 업과 최종 머지를 개별 PR 통과가 아니라 통합 상태 기준으로 보는 방식

## 버릴 것

- API 부재를 이유로 전체 스프린트를 멈추는 방식
- 임시 mock을 정본 service/API 계약처럼 취급하는 방식
- 병렬 task가 sibling task 완료를 자기 acceptance로 요구하는 방식
- mock 제거, 실제 service 연결, 버전 업 확인 없이 개별 PR 통과만으로 최종 머지를 판단하는 방식
- 프로젝트 내부 요구사항 원문을 0계층 운영 가설에 복사하는 방식

## 0계층 반영 위치와 추적 상태

- 문서 반영: 이 운영 가설 원문은 `system/60-operating-hypotheses/OH-0003-sprint-parallel-mock-contract.md`에만 확정 반영되어 있다.
- 관련 부분 반영: `setup.sh`가 생성하는 Project `AGENTS.md`와 task template에는 초기 DB mock data, test input, contract mock, harness 같은 관련 문구가 있으나, OH-0003의 `mock/stub/API 계약` 형식 전체를 task template이나 setup scaffold의 고정 필드로 반영한 것은 아니다.
- 관련 부분 반영: `system/20-skills/projects-setup/SKILL.md`, `system/10-agents/task-writer/README.md`, `system/10-agents/task-writer/main-prompt.md`에는 단일 task mock data/test input의 저장 계층과 mock data 정의 전 project registry/config 또는 Project SSoT 정본 위치 확인 기준이 있다. 다만 스프린트 병렬 mock 계약의 목적, 응답 shape, 실제 service 연결 예정 위치, 제거 조건, mock/stub 제거 대조표까지 요구하는 OH-0003 전용 계약 형식은 아직 고정하지 않았다.
- 미반영: OH-0003 전용 `mock/stub/API 계약` 형식을 task template 또는 setup scaffold에 넣는 변경은 아직 수행하지 않았다.
- 미반영: 스프린트 종료 gate의 mock/stub 제거 대조표를 task dashboard나 setup scaffold에 자동 연결하는 변경은 아직 수행하지 않았다.
- skill: 미반영. 현재는 `projects-setup`과 `task-writer` 계열 문서의 인접 guard만 확인됐고, OH-0003 전용 skill 절차는 없다.
- agent prompt: 부분 반영. `task-writer` prompt에는 mock data 정의 전 정본 위치 확인 기준이 있으나, OH-0003 전용 병렬 스프린트 mock/stub 계약 형식은 후속 반영 후보로 남긴다.

## 후속 운영 가설 후보

- 스프린트 종료 gate에서 mock 제거 대조표를 task dashboard와 자동 연결하면 통합 누락이 줄어드는가
- mock/stub/API 계약 형식을 task template에 넣으면 task별 임시 계약 drift가 줄어드는가
- 버전 업 후보를 project SSoT와 PR 본문에 동시에 기록하면 최종 머지 판단 비용이 줄어드는가

## 논리 자가검수

- [x] 필수 항목 포함: `system/00-system-overview/운영-가설-로그.md`의 필수 항목을 모두 포함했다.
- [x] Symptom-as-Cause 없음: API 부재, mock 잔존, 통합 병목을 원인이 아니라 기존 방식의 문제 또는 예상 병목으로 분리했다.
- [x] Scope Overreach 없음: 모든 프로젝트에 강제한다고 쓰지 않고 병렬 스프린트, 미성숙 service/API, 통합 gate가 필요한 작업으로 적용 범위를 제한했다.
- [x] Premature Conclusion 없음: 아직 실행 전인 항목은 `draft`, `아직 실행 전`으로 표시했다.
- [x] Missing Causal Step 없음: 병렬 slice 정의, 임시 계약 명시, 스프린트 종료 mock 제거, 실제 service 연결, 버전 업, 최종 머지 확인 순서로 인과 단계를 분리했다.
- [x] Effect Drift 없음: 채택 이유, 취합한 정보, 기존 방식의 문제, 예상 병목, 적용 방식, 사람 확인 지점을 섹션별 책임에 맞게 분리했다.
- 남은 위험: 실제 프로젝트에서 적용한 뒤 mock 제거 대조표의 비용과 효과를 다시 기록해야 한다.
