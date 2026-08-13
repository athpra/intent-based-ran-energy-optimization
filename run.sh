#!/usr/bin/env bash
set -e

VENV_DIR=".venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found. Run setup.sh first."
    exit 1
fi

source "$VENV_DIR/bin/activate"
jupyter notebook notebooks/
