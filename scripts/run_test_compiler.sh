#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)

DEFAULT_PYTHON_BIN="$REPO_DIR/torch213/.venv/bin/python"
if [[ ! -x "$DEFAULT_PYTHON_BIN" ]]; then
  DEFAULT_PYTHON_BIN="$REPO_DIR/.venv/bin/python"
fi

PYTHON_BIN=${PYTHON_BIN:-"$DEFAULT_PYTHON_BIN"}
TEST_FILE=${TEST_FILE:-"$REPO_DIR/test_compiler.py"}

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python interpreter not found: $PYTHON_BIN" >&2
  echo "Run 'uv sync --project torch213' first, or set PYTHON_BIN=/path/to/python." >&2
  exit 1
fi

"$SCRIPT_DIR/setup_local_xpu_userstack.sh" >/dev/null

export PATH="$SCRIPT_DIR:$PATH"

exec "$PYTHON_BIN" "$TEST_FILE"
