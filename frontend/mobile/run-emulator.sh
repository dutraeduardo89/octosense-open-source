#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

API_PORT="${API_PORT:-5137}"
API_BASE="${API_BASE:-http://10.0.2.2:${API_PORT}}"

if ! command -v flutter >/dev/null; then
  echo "flutter não está no PATH." >&2
  exit 1
fi

if ! command -v adb >/dev/null; then
  echo "adb não está no PATH." >&2
  exit 1
fi

device="${DEVICE:-}"
if [[ -z "$device" ]]; then
  device="$(adb devices | awk 'NR>1 && $2=="device" && $1 ~ /emulator/ { print $1; exit }')"
fi

if [[ -z "$device" ]]; then
  echo "Nenhum emulador Android conectado. Suba um AVD e rode de novo." >&2
  adb devices -l
  exit 1
fi

adb -s "$device" reverse "tcp:${API_PORT}" "tcp:${API_PORT}"
echo "Emulador: $device"
echo "App → API: $API_BASE"
echo "Chrome no emulador → localhost:${API_PORT} (adb reverse)"

flutter run -d "$device" --dart-define="API_BASE=${API_BASE}"