#!/bin/bash

# This script runs ruff to remove unused imports from Python files

# use black
black src tests

# Run ruff to find and fix unused imports
ruff check --select F401 --fix src tests

# sort imports
isort src tests

# Output a message after completion
echo "Unused imports have been removed!"