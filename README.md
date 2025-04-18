## Fireclub 개발 템플릿

Python 기반 개발에 필요한 환경을 Docker 기반으로 간편하게 구성할 수 있는 템플릿입니다. SSH, PostgreSQL, Jupyter, uv 등을 포함하여 일관된 개발 환경을 제공합니다.

---

## 주요 구성 요소

- uv 기반 Python 패키지 설치 (`pip`사용가능)
- PostgreSQL / TimescaleDB 연동 (SSH 포트포워딩 포함)
- Jupyter Notebook 실행/중지 제어 스크립트
- .env 기반 환경 구성 및 `docker-compose.yaml` 자동 생성
- Docker 콘테이너 기반의 개발 환경 템플릿

---

## 프로젝트 구성
init.py 실행 후 아래와 같이 프로젝트 세팅

```
project-name/
├─ bin/
│  ├─ jupyter.sh
│  └─ psql-tunnel.sh
├─ src/
│  └─ main.py
├─ Dockerfile
├─ docker-compose.yaml.template
├─ requirements.txt
└─ README.md
```

---

## 설치 방법

### 1. curl 설치 스크립트 실행

```bash
bash <(curl -sL https://raw.githubusercontent.com/fireclub2033/fireclub-boilerplate/main/install.sh) my-project
cd my-project
```

### 2. .env 설정

```bash
cp .env.example .env
vi .env
```

평범 값 예시:

```dotenv
PYTHON_VERSION=3.10
RUN_MODE=dev # 실행 모드 전달용

SSH_PORT=2222
REMOTE_USER=your_ssh_user
REMOTE_HOST=your.ssh.gateway.com
SSH_TUNNEL_PORT=15432

DB_HOST=your.database.internal      # SSH 터널링 대상 DB 주소
DB_PORT=5432
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_db_password

# JUPYTER_PASSWORD_HASH=sha1:xxxxx    # 필요 시 해시로 설정
JUPYTER_PORT=8888                   # 기본 포트 유지 가능
```

---

### 3. 개발 환경 세팅

```bash
python3 init.py              # 기본 실행
```
```bash
python3 init.py --keep-init  # 템플릿 파일 유지
```

---

## 컨테이너 실행 및 지방

```bash
docker compose up --build -d
```

```bash
docker exec -it <container-name> bash # docker 내부 shell 접속
```

---

## Jupyter Notebook 제어
컨테이너 내부에서:
```bash
bin/jupyter.sh start
bin/jupyter.sh stop
bin/jupyter.sh log
```

---

## PostgreSQL 포트포워딩 (SSH)
컨테이너 내부에서:
```bash
bin/psql-tunnel.sh start
bin/psql-tunnel.sh stop
bin/psql-tunnel.sh log

# 이후 접속
psql -h localhost -p 15432 -U $DB_USER -d $DB_NAME
```

---

## Python 패키지 설치 / 실행

컨테이너 내부에서:

```bash
uv pip install -r requirements.txt
python src/main.py
```

---

## 환경 변수 (컨테이너 내부)

| 변수명       | 설명                         |
|------------------|----------------------------------|
| RUN_MODE         | 실행 목록 (dev, prod 등)   |
| PROJECT_NAME     | 프로젝트 이름              |
| DB_HOST          | DB 주소                    |
| DB_PORT          | DB 포트                    |
| DB_NAME          | DB 이름                    |
| DB_USER          | DB 사용자                  |
| DB_PASSWORD      | DB 비밀번호                |
| REMOTE_HOST      | SSH 대상 호스트            |
| JUPYTER_PORT     | Jupyter 로케열 포트         |

Python 코드에서 `os.getenv("DB_HOST")` 방식으로 접근 가능

---

## 협업 최적 가정

- `.env`는 `.gitignore`에 포함해서 커미팅 금지
- `.env.example`은 공유의 기반으로 바로 포함
- `requirements.txt`로 의존성 고정 구현
- 개발/테스트는 모두 컨테이너 내부에서 수행
- 암호 등 무기적 정보는 추출적으로 포함 금지
