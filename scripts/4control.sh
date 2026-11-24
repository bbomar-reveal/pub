#!/bin/sh

CONTEXTS=("k3d-local-dev" "k3d-local-prod" "k3d-local-uat")

for CXT in $CONTEXTS; do
  