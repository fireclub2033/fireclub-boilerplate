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
    && rm -rf /var/lib/apt/lists/*

# Poetry 설치
ENV PATH="/root/.local/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    poetry config virtualenvs.create false && \
    poetry config installer.parallel false  # (간혹 오류 방지용)

# SSH 설정
RUN mkdir /var/run/sshd

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

# 코드 복사
WORKDIR /home/${CONTAINER_USER}/workspace
COPY workspace /home/${CONTAINER_USER}/workspace
RUN chown -R ${CONTAINER_USER}:${CONTAINER_USER} /home/${CONTAINER_USER}/workspace

# 사용자 전환 (중요: 이후 명령은 모두 일반 사용자 권한)
USER ${CONTAINER_USER}

# 의존성 설치 (poetry.lock이 없을 수도 있으므로 실패 허용)
RUN poetry install || true

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
