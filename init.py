import os
import subprocess
from pathlib import Path

# 폴더명을 프로젝트명으로 사용
def get_project_name():
    return Path.cwd().name.replace(" ", "-").lower()

# .env 파일 로드
def load_env():
    env_path = Path(".env")
    if not env_path.exists():
        raise FileNotFoundError("[ERROR] .env file not exist.")
    env = {}
    with env_path.open() as f:
        for line in f:
            if line.strip() and not line.startswith("#"):
                key, val = line.strip().split("=", 1)
                env[key] = val
    return env

# docker-compose.yaml 생성
def render_compose(env, project_name, run_mode):
    with open("docker-compose.yaml.template") as f:
        template = f.read()

    container_name = f"{project_name}-{run_mode}"
    image_name = f"{project_name}:{run_mode}"

    yaml = template.format(
        container_name=container_name,
        container_user=env.get("CONTAINER_USER", "devuser"),
        container_pass = env.get("CONTAINER_PASS", "devpass"),
        python_version=env.get("PYTHON_VERSION", "3.10"),
        ssh_port=env.get("SSH_PORT", "2222"),
        image=image_name,
        run_mode=run_mode
    )

    with open("docker-compose.yaml", "w") as f:
        f.write(yaml)

    print(f"[INFO] generate docker-compose.yaml (container: {container_name}, image: {image_name})")

# 실행 중인 컨테이너 확인
def check_docker_status(container_name):
    print(f"[INFO] Checking running containers:")
    subprocess.run(["docker", "ps", "--filter", f"name={container_name}", "--format", "table {{.Names}}\t{{.Status}}\t{{.Ports}}"])

# 메인 함수
def main():
    project_name = get_project_name()
    env = load_env()
    run_mode = env.get("RUN_MODE", "dev")

    # 환경 변수 반영 (docker-compose에서 ${VAR} 형식 사용 가능하게)
    os.environ.update(env)

    render_compose(env, project_name, run_mode)

    print("[INFO] Start Docker Compose ...")
    subprocess.run(["docker-compose", "up", "--build", "-d"])

    check_docker_status(f"{project_name}-{run_mode}")

if __name__ == "__main__":
    main()
