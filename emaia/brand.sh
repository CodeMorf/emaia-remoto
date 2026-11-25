#!/usr/bin/env bash
# EMAIA Remoto branding, applied on top of upstream RustDesk before building.
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="166.1.88.159"
KEY="HQ1N66YOztaWBlHAGg7HWUuj1cMwehfxKkKxdomhDkA="
APP="EmaiaRemoto"

C=libs/hbb_common/src/config.rs
sed -i "s|pub const RENDEZVOUS_SERVERS: &\[&str\] = &\[\"rs-ny.rustdesk.com\"\];|pub const RENDEZVOUS_SERVERS: \&[\&str] = \&[\"$HOST\"];|" "$C"
sed -i "s|pub const RS_PUB_KEY: &str = \"[^\"]*\";|pub const RS_PUB_KEY: \&str = \"$KEY\";|" "$C"
sed -i "s|APP_NAME: RwLock<String> = RwLock::new(\"RustDesk\".to_owned())|APP_NAME: RwLock<String> = RwLock::new(\"$APP\".to_owned())|" "$C"

grep -q "\"$HOST\"" "$C" || { echo "server patch failed"; exit 1; }
grep -q "$KEY" "$C" || { echo "key patch failed"; exit 1; }
grep -q "\"$APP\".to_owned()" "$C" || { echo "app name patch failed"; exit 1; }
echo "EMAIA branding applied"