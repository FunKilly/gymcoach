#!/bin/bash

# Run isort in check mode
echo "Running isort..."
isort --check-only src tests

if [ $? -ne 0 ]; then
    echo "isort failed. Please sort your imports."
    exit 1
fi

# Run black in check mode
echo "Running black..."
black --check src tests

if [ $? -ne 0 ]; then
    echo "black failed. Please format your code."
    exit 1
fi

# Run flake8 for linting
echo "Running flake8..."
flake8 src tests

if [ $? -ne 0 ]; then
    echo "flake8 failed. Please fix the linting issues."
    exit 1
fi

echo "All checks passed!"