#!/usr/bin/env bash
set -e

VENV_DIR=".venv"
KERNEL_NAME="es-blueprint-rsg"
REQUIRED_PYTHON="3.10"

echo "=== ES Blueprint RSG - Setup ==="

# Find Python 3.10+
PYTHON_BIN=""
for cmd in python3.12 python3.11 python3.10 python3 python; do
    if command -v "$cmd" &> /dev/null; then
        minor=$("$cmd" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | cut -d. -f2)
        if [ "$minor" -ge 10 ] 2>/dev/null; then
            PYTHON_BIN="$cmd"
            break
        fi
    fi
done

# If Python 3.10+ not found, install via pyenv
if [ -z "$PYTHON_BIN" ]; then
    echo "Python 3.10+ not found. Installing Python $REQUIRED_PYTHON via pyenv..."

    # Install pyenv if not available
    if ! command -v pyenv &> /dev/null; then
        if [ -d "$HOME/.pyenv" ]; then
            echo "Found existing pyenv installation, initializing..."
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init -)"
        else
            echo "Installing pyenv..."
            curl -fsSL https://pyenv.run | bash
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init -)"
        fi
    fi

    # Install Python
    pyenv install -s "$REQUIRED_PYTHON"
    PYTHON_BIN="$(pyenv prefix $REQUIRED_PYTHON)/bin/python"
fi

echo "Using $PYTHON_BIN ($($PYTHON_BIN --version))"

# Create virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    "$PYTHON_BIN" -m venv "$VENV_DIR"
else
    echo "Virtual environment already exists, skipping creation."
fi

# Activate
source "$VENV_DIR/bin/activate"

# Install dependencies
echo "Installing dependencies..."
pip install -q --no-user --upgrade pip
pip install -q --no-user -r requirements.txt

# Register Jupyter kernel
echo "Registering Jupyter kernel: $KERNEL_NAME"
python -m ipykernel install --sys-prefix --name="$KERNEL_NAME" --display-name="ES Blueprint RSG"

# Setup .env
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env from .env.example — fill in your values."
else
    echo ".env already exists, skipping."
fi

echo ""
echo "=== Setup complete ==="
echo "To activate the virtual environment, run:"
echo "  source $VENV_DIR/bin/activate"
echo ""
echo "Then start the notebook:"
echo "  jupyter notebook notebooks/"
echo "Make sure to select kernel '$KERNEL_NAME' in the notebook."
