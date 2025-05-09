import os
import sys
import shutil
from pathlib import Path
from string import Template
import subprocess

ROOT_DIR = Path.cwd()
WORKSPACE_DIR = ROOT_DIR / "workspace"
ENV_PATH = ROOT_DIR / ".env"
ENV_EXAMPLE_PATH = ROOT_DIR / ".env.example"
COMPOSE_TEMPLATE = WORKSPACE_DIR / "docker-compose.yaml.template"
COMPOSE_OUTPUT = ROOT_DIR / "docker-compose.yaml"

def log(msg):
    print(f"[INFO] {msg}")

def error(msg):
    print(f"[ERROR] {msg}")
    sys.exit(1)

def load_env():
    if not ENV_PATH.exists():
        if ENV_EXAMPLE_PATH.exists():
            shutil.copy(ENV_EXAMPLE_PATH, ENV_PATH)
            error(".env 파일이 없어 .env.example 을 복사했습니다. .env를 수정한 후 다시 실행하세요.")
        else:
            error(".env 파일과 .env.example 모두 없습니다.")
    env = {}
    with ENV_PATH.open() as f:
        for line in f:
            if line.strip() and not line.startswith("#"):
                key, val = line.strip().split("=", 1)
                env[key] = val
    os.environ.update(env)
    return env

def get_project_name():
    return ROOT_DIR.name.replace(" ", "-").lower()

def render_compose(env, project_name, run_mode):
    with COMPOSE_TEMPLATE.open() as f:
        template = Template(f.read())

    container_name = f"{project_name}-{run_mode}"
    image_name = f"{project_name}:{run_mode}"

    content = template.substitute({
        "container_name": container_name,
        "container_user": env.get("CONTAINER_USER", "devuser"),
        "image": image_name,
        "project_name": project_name,
    })

    with COMPOSE_OUTPUT.open("w") as f:
        f.write(content)

    log(f"docker-compose.yaml 생성 완료 (container: {container_name}, image: {image_name})")

def copy_workspace_contents():
    targets = ["Dockerfile", "pyproject.toml", "bin", "src", "requirements.txt", ".gitignore"]
    for name in targets:
        src = WORKSPACE_DIR / name
        dst = ROOT_DIR / name
        if src.is_dir():
            shutil.copytree(src, dst, dirs_exist_ok=True)
        elif src.is_file():
            shutil.copy2(src, dst)
    log("workspace 내 파일 복사 완료")

def remove_git_folder():
    git_dir = ROOT_DIR / ".git"
    if git_dir.exists() and git_dir.is_dir():
        shutil.rmtree(git_dir)
        log(".git 디렉토리 삭제 완료")

def cleanup(keep=False):
    if not keep:
        shutil.rmtree(WORKSPACE_DIR, ignore_errors=True)
        Path(__file__).unlink(missing_ok=True)
        ENV_EXAMPLE_PATH.unlink(missing_ok=True)
        log("init.py, workspace/, .env.example 삭제 완료")
    else:
        log("--keep-init 사용됨: 파일 유지")

def uv_init():
    if not (ROOT_DIR / "pyproject.toml").exists():
        subprocess.run(["uv", "init", "--yes"], check=True)
        log("uv init으로 pyproject.toml 생성 완료")
        req = ROOT_DIR / "requirements.txt"
        if req.exists():
            subprocess.run(["uv", "add", "-r", "requirements.txt"], check=True)
            log("requirements.txt의 패키지를 pyproject.toml에 추가 완료")
    subprocess.run(["uv", "venv"], check=True)

def main():
    keep_files = "--keep-init" in sys.argv

    log("초기화 시작")
    project_name = get_project_name()
    env = load_env()
    run_mode = env.get("RUN_MODE", "dev")

    copy_workspace_contents()
    render_compose(env, project_name, run_mode)
    remove_git_folder()
    cleanup(keep=keep_files)
    uv_init()

    log("개발 환경 초기화 완료. docker-compose up 으로 컨테이너를 시작하세요.")

if __name__ == "__main__":
    main()
