#!/bin/bash

# This script runs ruff to remove unused imports from Python files

# use black
black .

# Run ruff to find and fix unused imports
ruff check --select F401 --fix .

# sort imports
isort .

# Output a message after completion
echo "Unused imports have been removed!"