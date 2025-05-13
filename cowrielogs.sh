#!/bin/bash

LOG_PATH="/home/yourusername/tpotce/data/cowrie/log/cowrie.json"

if [[ ! -f "$LOG_PATH" ]]; then
  echo -e "\033[0;31m[!] Cowrie JSON log not found at: $LOG_PATH\033[0m"
  exit 1
fi

echo -e "\033[0;36m[*] Parsing and correlating Cowrie session + command data...\033[0m"

# Temp session storage
declare -A SESS_TS
declare -A SESS_IP
declare -A SESS_SENSOR
declare -A SESS_USER
declare -A SESS_PASS

# First pass: gather session metadata from *any* session-related events
while IFS= read -r line; do
  event=$(echo "$line" | jq -r '.eventid // empty')

  if [[ "$event" == "cowrie.session.connect" ]]; then
    session=$(echo "$line" | jq -r '.session // empty')
    ts=$(echo "$line" | jq -r '.timestamp // "-"')
    ip=$(echo "$line" | jq -r '.src_ip // "-"')
    sensor=$(echo "$line" | jq -r '.sensor // "-"')
    SESS_TS["$session"]="$ts"
    SESS_IP["$session"]="$ip"
    SESS_SENSOR["$session"]="$sensor"
  elif [[ "$event" == "cowrie.login.success" ]]; then
    session=$(echo "$line" | jq -r '.session // empty')
    user=$(echo "$line" | jq -r '.username // "-"')
    pass=$(echo "$line" | jq -r '.password // "-"')
    SESS_USER["$session"]="$user"
    SESS_PASS["$session"]="$pass"
  fi
done < "$LOG_PATH"

# Second pass: handle command input
while IFS= read -r line; do
  event=$(echo "$line" | jq -r '.eventid // empty')
  [[ "$event" != "cowrie.command.input" ]] && continue

  session=$(echo "$line" | jq -r '.session // "-"')
  cmd=$(echo "$line" | jq -r '.input // "-"')
  user="${SESS_USER["$session"]:-"-"}"
  pass="${SESS_PASS["$session"]:-"-"}"
  file=$(echo "$line" | jq -r '.filename // "-"')

  ts="${SESS_TS["$session"]:-"-"}"
  ip="${SESS_IP["$session"]:-"-"}"
  sensor="${SESS_SENSOR["$session"]:-"-"}"

  echo -e "\033[0;36m\n🕒 Date/Time   $ts"
  echo -e "📦 Sensor      $sensor"
  echo -e "🌐 IP Address  $ip"
  echo -e "\033[1;33m🔑 Login       \033[0m$user/$pass"
  echo -e "\033[0;32m💻 Command     $cmd\033[0m"
  echo -e "\033[0;31m📁 File        $file\033[0m"
  echo -e "\033[0;90m──────────────────────────────────────────────\033[0m"
done < "$LOG_PATH"
