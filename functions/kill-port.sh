# kill-port - Kill process running on a specific port

kill-port() {
  if [[ -z $1 ]]; then
    echo "Usage: kill-port <port-number>"
    return 1
  fi

  local pids
  pids=$(lsof -ti:"$1" 2>/dev/null)

  if [[ -z $pids ]]; then
    echo "No process on port $1"
    return 0
  fi

  echo "Killing PIDs: $pids"
  echo "$pids" | xargs kill -9
}
