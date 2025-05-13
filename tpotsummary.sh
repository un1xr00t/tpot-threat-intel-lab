#!/bin/bash

KIBANA_USER="admin"
KIBANA_PASS="yourpassword"
ES_URL="http://localhost:64298"

echo -e "\033[0;36m[*] Pulling ALL honeypot logs from T-Pot Elasticsearch (most recent 100)...\033[0m"

curl -s -u "$KIBANA_USER:$KIBANA_PASS" "$ES_URL/logstash-*/_search" \
  -H 'Content-Type: application/json' \
  -d '{
    "_source": [
      "@timestamp", "src_ip", "dest_ip", "type", "path",
      "ip_rep", "operation_mode",
      "attack_connection", "proxy_connection"
    ],
    "query": {
      "match_all": {}
    },
    "sort": [{ "@timestamp": { "order": "desc" } }],
    "size": 100
  }' | jq -r '
  .hits.hits[] | ._source as $s |
  "\u001b[1;37m🕒  \u001b[0m" + ($s["@timestamp"] // "-") + "\n" +
  "\u001b[1;34m📦  \u001b[0m" + ($s.type // "-") + "\n" +
  "\u001b[1;36m🌐  \u001b[0m" + ($s.src_ip // "-") + " → " + ($s.dest_ip // "-") + "\n" +
  "\u001b[1;33m🔍  \u001b[0mReputation: " + ($s.ip_rep // "-") + "\n" +
  "\u001b[1;32m🧬  \u001b[0mMD5: " + ($s.attack_connection.payload.md5_hash // "-") + "\n" +
  "\u001b[1;31m🔐  \u001b[0mSHA512: " + ($s.proxy_connection.payload.sha512_hash // "-") + "\n" +
  "\u001b[0;90m──────────────────────────────────────────────\u001b[0m"
'
