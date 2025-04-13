# Fireclub 개발 템플릿

Python 기반 라이브러리를 효율적으로 개발하고 협업하며, 빠르게 배포할 수 있도록 구성된 **컨테이너 기반 개발 환경 템플릿**입니다. Poetry, PostgreSQL, SSH, Jupyter, Docker를 통합하여 일관된 개발 환경을 제공 하고자 합니다.

---

## 🧰 주요 구성 요소

- **Poetry 기반 Python 패키지 관리**
- **PostgreSQL/TimescaleDB 연동 세팅** 및 SSH 포트포워딩 지원
- **Jupyter Notebook 제어 스크립트** 포함
- **.env 기반 환경 자동 구성** 및 템플릿 자동 생성
- **Docker 개발 컨테이너 자동 실행**
- **라이브러리 빌드 및 배포 지원 (PyPI 또는 GitHub)**

---

## 📁 프로젝트 구조

```
project-name/
├── Dockerfile                         # Python + SSH + PostgreSQL client + Poetry
├── docker-compose.yaml.template       # 템플릿 기반 docker-compose.yaml 생성용
├── init.py                            # .env 읽고 docker-compose.yaml 자동 생성 및 실행
├── .env.example                       # 환경 변수 예시 파일
├── workspace/
│   ├── pyproject.toml                 # Poetry 설정 파일
│   ├── bin/
│   │   ├── jupyter.sh                 # Jupyter 실행/중지 스크립트
│   │   └── psql-tunnel.sh             # DB SSH 포트포워딩 스크립트
│   ├── src/
│   │   └── main.py                    # 예시: 환경 변수 출력 스크립트
│   └── README.md
```

---

## ⚙️ 사용 방법

### 1. 환경 설정

```bash
cp .env.example .env  # .env 파일 생성 후 원하는 값으로 수정
```

예시 `.env`:

```dotenv
PYTHON_VERSION=3.10
RUN_MODE=dev

SSH_PORT=22
REMOTE_USER=your_ssh_user
REMOTE_HOST=your.host.com            # 접근 서버 주소

DB_HOST=your.database.server.com     # 실제 PostgreSQL DB 서버 주소
DB_PORT=5432
SSH_TUNNEL_PORT=15432
DB_NAME=DB_dev
DB_USER=irteam
DB_PASSWORD=securepass
```

### 2. Docker 컨테이너 빌드 및 실행

```bash
python init.py
```

### 3. 컨테이너 내부 진입

```bash
docker exec -it project-name-dev bash
```

---

## 🧪 로컬 개발 툴 사용

### Jupyter Notebook 실행

```bash
workspace/bin/jupyter.sh start
```

### Jupyter Notebook 중지

```bash
workspace/bin/jupyter.sh stop
```

---

## 🔐 원격 PostgreSQL 접근 (SSH 포트포워딩)

원격 서버의 PostgreSQL에 안전하게 접근하려면 아래 명령을 실행하세요:

```bash
workspace/bin/psql-tunnel.sh
```

이후 로컬에서 다음과 같이 접속 가능합니다:

```bash
psql -h localhost -p 15432 -U irteam -d DB_dev
```

---

## 🛠 라이브러리 테스트 및 빌드

### 테스트 실행

```bash
poetry run pytest
```

### 패키지 빌드 & 버전 관리

```bash
poetry version patch   # 또는 minor / major
poetry build
```

### PyPI 또는 GitHub 패키지 배포

```bash
poetry publish
```

최초 배포 시 토큰 설정 필요:

```bash
poetry config pypi-token.pypi <your-token>
```

---

## 🚀 라이브러리 사용 예시 (다른 프로젝트에서)

```bash
pip install git+https://github.com/your-org/project-name.git
```

또는 PyPI, GitHub Package Registry 등 사설 저장소에도 배포 가능합니다.

---

## 🌐 컨테이너 내부에서 자동으로 설정되는 환경 변수

컨테이너 내부에서는 다음 환경 변수들이 자동으로 설정되어 있습니다:

| 변수명         | 설명                         |
|----------------|------------------------------|
| `RUN_MODE`     | dev, prod 등 실행 모드       |
| `PROJECT_NAME` | 현재 프로젝트 폴더명 기반 이름 |
| `DB_HOST`      | DB 서버 주소                 |
| `DB_PORT`      | DB 포트 번호                 |
| `DB_NAME`      | 사용할 DB 이름               |
| `DB_USER`      | DB 접속 계정                 |
| `DB_PASSWORD`  | DB 접속 비밀번호             |
| `REMOTE_HOST`  | SSH 포트포워딩 대상 서버 주소 |

Python 코드 내부에서 `os.getenv("DB_HOST")` 등으로 읽을 수 있습니다.

---

## 🤝 협업 워크플로우 권장 사항

- `.env.example`은 모든 프로젝트에 포함하여 기본 설정 공유
- `.env` 파일은 `.gitignore`에 포함하여 커밋 금지
- `poetry.lock`으로 버전 고정하여 재현성 확보
- 컨테이너 내부에서 개발/테스트 후 릴리즈
- `key`, `password`, `id` 등 업로드 주의

---

## 📎 확장 팁
- MLFlow, Airflow, Redis 등의 서비스도 `docker-compose`에 추가 가능합니다
- GitHub Actions와 연동하여 CI 테스트/배포 자동화도 고려할 수 있습니다

---

## 📮 기여

이 템플릿은 자유롭게 수정 및 확장 가능합니다.\
개선사항은 PR로 환영합니다! 🛠️