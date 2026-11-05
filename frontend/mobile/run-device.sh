#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

API_PORT="${API_PORT:-5137}"
API_BASE="${API_BASE:-http://localhost:${API_PORT}}"

if ! command -v flutter >/dev/null; then
  echo "flutter não está no PATH." >&2
  exit 1
fi

if ! command -v adb >/dev/null; then
  echo "adb não está no PATH." >&2
  exit 1
fi

# Detecta um device físico (não emulador)
device="${DEVICE:-}"
if [[ -z "$device" ]]; then
  device="$(adb devices | awk 'NR>1 && $2=="device" && $1 !~ /emulator/ { print $1; exit }')"
fi

if [[ -z "$device" ]]; then
  echo "Nenhum celular físico conectado. Conecte via USB e autorize." >&2
  adb devices -l
  exit 1
fi

# Redireciona localhost:5137 do celular para a porta 5137 do PC
adb -s "$device" reverse "tcp:${API_PORT}" "tcp:${API_PORT}"
echo "Celular: $device"
echo "App → API: $API_BASE (via adb reverse)"
echo ""

flutter run -d "$device" --dart-define="API_BASE=${API_BASE}"
