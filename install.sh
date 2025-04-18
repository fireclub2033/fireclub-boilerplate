#!/bin/bash

set -e

REPO_URL="https://github.com/fireclub2033/fireclub-boilerplate.git"
TARGET_DIR=$1

if [ -z "$TARGET_DIR" ]; then
  echo "[ERROR] 프로젝트 폴더명을 인자로 전달해야 합니다."
  echo "사용법: bash install.sh <project-directory>"
  exit 1
fi

if [ -d "$TARGET_DIR" ]; then
  echo "[ERROR] '$TARGET_DIR' 폴더가 이미 존재합니다."
  exit 1
fi

echo "[INFO] 템플릿을 '$TARGET_DIR' 에 설치합니다..."

git clone "$REPO_URL" "$TARGET_DIR"
cd "$TARGET_DIR"

cp .env.example .env
echo "[INFO] .env 파일이 생성되었습니다. 프로젝트 설정을 위해 .env 파일을 수정하세요."
echo "[INFO] 설정 후, 'python3 init.py' 또는 'python3 init.py --keep-init' 명령어를 실행하세요."
