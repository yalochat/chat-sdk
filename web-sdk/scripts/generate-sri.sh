#!/usr/bin/env bash
# Copyright (c) Yalochat, Inc. All rights reserved.
#
# Generates a Subresource Integrity (SRI) artifact next to each built bundle.
# Consumers paste the value into the `integrity` attribute of their <script> tag.

set -euo pipefail

cd "$(dirname "$0")/.."

shopt -s nullglob
bundles=(dist/v*/sdk.js)

if [ ${#bundles[@]} -eq 0 ]; then
  echo "generate-sri: no bundles found under dist/v*/sdk.js" >&2
  exit 1
fi

for bundle in "${bundles[@]}"; do
  hash=$(openssl dgst -sha384 -binary "$bundle" | openssl base64 -A)
  integrity="sha384-${hash}"
  printf '%s\n' "$integrity" > "${bundle}.sri"
  echo "Wrote ${bundle}.sri (${integrity})"
done
