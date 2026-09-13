#!/usr/bin/env bash
set -euo pipefail
MIUIX_DIR="$(cd "$(dirname "$0")" && pwd)"
QML4J_DIR="${QML4J_DIR:-$MIUIX_DIR/../qml4j}"
export QML4J_DARK="${QML4J_DARK:-false}"
exec "$QML4J_DIR/run.sh" "$MIUIX_DIR" "${1:-showcases/MiuixShowcase.qml}"
