#!/bin/bash
# workspace/bin/jupyter.sh

LOG_DIR="$HOME/.fireclub/logs"
PID_FILE="$LOG_DIR/jupyter.pid"
LOG_FILE="$LOG_DIR/jupyter.log"
mkdir -p "$LOG_DIR"

: ${JUPYTER_PORT:=8888}

log() {
  local level="$1"; shift
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp [$level] $*"
}

case $1 in
  start)
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
      log INFO "Jupyter is already running (PID: $(cat $PID_FILE))"
    else
      log INFO "Starting Jupyter Notebook... Logging to: $LOG_FILE"
      nohup jupyter notebook --ip=0.0.0.0 --port=$JUPYTER_PORT \
        --no-browser > "$LOG_FILE" 2>&1 &
      echo $! > "$PID_FILE"
      log INFO "Jupyter started with PID $(cat $PID_FILE)"
    fi
    ;;
  stop)
    if [ -f "$PID_FILE" ]; then
      log INFO "Stopping Jupyter (PID: $(cat $PID_FILE))"
      if kill $(cat "$PID_FILE"); then
        rm "$PID_FILE"
        log INFO "Jupyter stopped."
      else
        log ERROR "Failed to stop Jupyter."
      fi
    else
      log WARN "No Jupyter process found."
    fi
    ;;
  log)
    log INFO "Tailing Jupyter log at $LOG_FILE"
    tail -f "$LOG_FILE"
    ;;
  *)
    echo "Usage: jupyter.sh {start|stop|log}"
    ;;
esac
