ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION}-slim

# 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    openssh-server \
    git \
    vim \
    curl \
    net-tools \
    libpq-dev \
    postgresql-client \
    jq \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# uv 설치 (pip 호환 CLI)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv

# SSH 설정
RUN mkdir /var/run/sshd

# 유저 설정
ARG CONTAINER_USER
ARG CONTAINER_PASS
RUN useradd -m -s /bin/bash ${CONTAINER_USER} && \
    echo "${CONTAINER_USER}:${CONTAINER_PASS}" | chpasswd && \
    adduser ${CONTAINER_USER} sudo && \
    mkdir -p /home/${CONTAINER_USER}/.ssh && \
    chown -R ${CONTAINER_USER}:${CONTAINER_USER} /home/${CONTAINER_USER}

# SSH 데몬 설정
RUN sed -i 's/#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "Port 22" >> /etc/ssh/sshd_config

# 작업 디렉토리 설정
WORKDIR /home/${CONTAINER_USER}/workspace

# 전체 코드 복사
COPY src/ ./src/
COPY bin/ ./bin/
COPY requirements.txt ./

RUN chown -R ${CONTAINER_USER}:${CONTAINER_USER} /home/${CONTAINER_USER}/workspace

# 유저 전환
USER ${CONTAINER_USER}

# 의존성 설치 (requirements.txt가 없는 경우 무시)
RUN test -f requirements.txt && uv pip install -r requirements.txt || true

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
