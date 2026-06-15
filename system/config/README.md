# Config 템플릿

`system/config/`는 `setup.sh --init-config`가 복사할 local config 템플릿만 둡니다.

남기는 파일:

- `silo-runtime.env.example`
- `silo-projects.example.yaml`
- `shared-runtime-registry.example.yaml`

실제 값 파일은 git에 올리지 않습니다.

- `silo-runtime.env`
- `silo-projects.yaml`
- `silo-secrets.yaml`
- `shared-runtime-registry.yaml`
- `*.local.yaml`

세부 정책은 아래 문서를 기준으로 봅니다.

- 사일로 구조: `../30-silo-system/README.md`
- runtime set: `../30-silo-system/40-silo-runtime-set/README.md`
- Run Set: `../30-silo-system/40-silo-runtime-set/run-set.md`
