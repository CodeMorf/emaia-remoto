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
# Remote screen always fits the window (upstream desktop default is "original" 1:1)
sed -i 's|keys::OPTION_VIEW_STYLE => self.get_string(key, "original", vec!\["adaptive"\])|keys::OPTION_VIEW_STYLE => self.get_string(key, "adaptive", vec!["original"])|' "$C"
if grep -q '"original", vec!\["adaptive"\]' "$C"; then echo "view style patch failed"; exit 1; fi

# Hide upstream credit line and "set up your own server" tip (client-facing; EMAIA brand only)
D=flutter/lib/common.dart
sed -i 's|if (bind.mainGetBuildinOption(key: "hide-powered-by-me") == '"'"'Y'"'"') {|if (true) { // EMAIA: no provider credit in UI|' "$D"
grep -q 'if (true) { // EMAIA: no provider credit in UI' "$D" || { echo "powered-by patch failed"; exit 1; }
P=flutter/lib/desktop/pages/connection_page.dart
sed -i 's|if (!isIncomingOnly) setupServerWidget(),|// EMAIA: own server is built in, no setup tip|' "$P"
if grep -q 'if (!isIncomingOnly) setupServerWidget(),' "$P"; then echo "setup tip patch failed"; exit 1; fi

echo "EMAIA branding applied"