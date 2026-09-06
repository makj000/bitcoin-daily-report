#!/bin/zsh
set -u

PROJECT_DIR="/Users/kma/dev/finance/crypto/bitcoin-daily-report"
CODEX="/Users/kma/.local/bin/codex"
LOG_DIR="$PROJECT_DIR/logs"
REPORT_DIR="$PROJECT_DIR/reports"
LOCK_DIR="$PROJECT_DIR/.daily-report.lock"

export HOME="/Users/kma"
export PATH="/Users/kma/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

if [[ -f "$HOME/.config/kma/telegram.env" ]]; then
  set -a
  source "$HOME/.config/kma/telegram.env"
  set +a
fi
if [[ -f "$PROJECT_DIR/.env" ]]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

if [[ -z "${DRIVE_DIR:-}" ]]; then
  print "DRIVE_DIR not set — configure it in .env (see .env.example)"
  exit 1
fi

send_telegram() {
  local token="$1"
  local chat_id="$2"
  local text="$3"
  if [[ -z "$token" || -z "$chat_id" ]]; then
    print "Telegram notification skipped: missing token or chat ID"
    return 1
  fi
  curl -sS --max-time 15 \
    -X POST "https://api.telegram.org/bot${token}/sendMessage" \
    --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "text=${text}" >/dev/null
}

mkdir -p "$LOG_DIR" "$REPORT_DIR" "$DRIVE_DIR"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  print "A daily report run is already in progress."
  exit 0
fi
trap 'rmdir "$LOCK_DIR"' EXIT

cd "$PROJECT_DIR" || exit 1

{
  print "===== $(date '+%Y-%m-%d %H:%M:%S %Z') ====="
  "$CODEX" --search exec \
    --ephemeral \
    --sandbox workspace-write \
    --cd "$PROJECT_DIR" \
    "Execute the Daily BTC + ETH Market Report task in AGENTS.md autonomously. Complete steps 1-4. The wrapper handles Google Drive and Telegram delivery. Do not ask questions."

  REPORT_DATE="$(date '+%Y-%m-%d')"
  REPORT="$REPORT_DIR/daily_crypto_report_$REPORT_DATE.html"
  DRIVE_REPORT="$DRIVE_DIR/📊 BTC ETH Daily Report — $REPORT_DATE.html"

  if [[ ! -f "$REPORT" ]]; then
    print "Report was not created: $REPORT"
    exit 1
  fi

  cp "$REPORT" "$DRIVE_REPORT"

  DRIVE_ID=""
  for attempt in {1..30}; do
    DRIVE_ID="$(xattr -p 'com.google.drivefs.item-id#S' "$DRIVE_REPORT" 2>/dev/null || true)"
    [[ -n "$DRIVE_ID" ]] && break
    sleep 2
  done

  if [[ -z "$DRIVE_ID" ]]; then
    print "Google Drive did not assign a file ID."
    exit 1
  fi

  DRIVE_URL="https://drive.google.com/file/d/$DRIVE_ID/view"
  BTC_PRICE="$(sed -n 's/.*<meta name="btc-price" content="\([^"]*\)".*/\1/p' "$REPORT" | head -1)"
  ETH_PRICE="$(sed -n 's/.*<meta name="eth-price" content="\([^"]*\)".*/\1/p' "$REPORT" | head -1)"
  BTC_CHANGE="$(sed -n 's/.*<meta name="btc-change" content="\([^"]*\)".*/\1/p' "$REPORT" | head -1)"
  ETH_CHANGE="$(sed -n 's/.*<meta name="eth-change" content="\([^"]*\)".*/\1/p' "$REPORT" | head -1)"
  FNG="$(sed -n 's/.*<meta name="fear-greed" content="\([^"]*\)".*/\1/p' "$REPORT" | head -1)"

  NOTIFICATION_TEXT="📊 BTC/ETH Daily $REPORT_DATE | BTC: $BTC_PRICE ($BTC_CHANGE) | ETH: $ETH_PRICE ($ETH_CHANGE) | F&G: ${FNG:-N/A} | Report saved to Google Drive"

  TELEGRAM_CHAT_ID="${CRYPTO_TELEGRAM_CHAT_ID:-${KMA_TELEGRAM_CHAT_ID:-}}"
  if ! send_telegram "${CRYPTO_TELEGRAM_BOT_TOKEN:-}" "$TELEGRAM_CHAT_ID" "$NOTIFICATION_TEXT
$DRIVE_URL"; then
    print "Telegram notification failed"
    print "[$(date '+%Y-%m-%d %H:%M:%S %Z')] BTC: $BTC_PRICE ($BTC_CHANGE) | ETH: $ETH_PRICE ($ETH_CHANGE) | Report: reports/daily_crypto_report_$REPORT_DATE.html" >> "$PROJECT_DIR/notifications.log"
  fi
} >> "$LOG_DIR/daily-report.log" 2>&1
