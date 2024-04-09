#!/bin/bash

TEMPLATE_NAME="fedora-38"

if ! qvm-template list | grep -q "$TEMPLATE_NAME"; then
  echo "Template $TEMPLATE_NAME not found. Installing..."
  sudo qvm-template install $TEMPLATE_NAME
else
  echo "Template $TEMPLATE_NAME already installed."
fi
