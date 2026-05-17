#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
find .data -maxdepth 1 -name '*tpl*' -delete
