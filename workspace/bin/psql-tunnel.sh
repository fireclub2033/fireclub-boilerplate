#!/bin/bash
# workspace/bin/psql-tunnel.sh

LOG_DIR="$HOME/.fireclub/logs"
PID_FILE="$LOG_DIR/psql-tunnel.pid"
LOG_FILE="$LOG_DIR/psql-tunnel.log"
mkdir -p "$LOG_DIR"

# Load environment variables from .env
ENV_PATH="$(dirname $0)/../../.env"
if [ -f "$ENV_PATH" ]; then
  export $(grep -v '^#' "$ENV_PATH" | xargs)
fi

log() {
  local level="$1"; shift
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp [$level] $*"
}

REMOTE_USER=${REMOTE_USER:-devuser}
REMOTE_HOST=${REMOTE_HOST:-127.0.0.1}
REMOTE_DB_HOST=${DB_HOST:-localhost}
REMOTE_DB_PORT=${DB_PORT:-5432}
LOCAL_PORT=${SSH_TUNNEL_PORT:-15432}

case $1 in
  start)
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
      log INFO "Tunnel is already running (PID: $(cat $PID_FILE))"
    else
      log INFO "Establishing SSH tunnel: localhost:$LOCAL_PORT -> $REMOTE_DB_HOST:$REMOTE_DB_PORT via $REMOTE_HOST"
      nohup ssh -N -L ${LOCAL_PORT}:${REMOTE_DB_HOST}:${REMOTE_DB_PORT} ${REMOTE_USER}@${REMOTE_HOST} \
        > "$LOG_FILE" 2>&1 &
      echo $! > "$PID_FILE"
      log INFO "Tunnel started with PID $(cat $PID_FILE)"
    fi
    ;;
  stop)
    if [ -f "$PID_FILE" ]; then
      log INFO "Stopping SSH tunnel (PID: $(cat $PID_FILE))"
      kill $(cat "$PID_FILE") && rm "$PID_FILE"
      log INFO "Tunnel stopped."
    else
      log WARN "No active tunnel found."
    fi
    ;;
  log)
    log INFO "Tailing tunnel log at $LOG_FILE"
    tail -f "$LOG_FILE"
    ;;
  *)
    echo "Usage: psql-tunnel.sh {start|stop|log}"
    ;;
esac
