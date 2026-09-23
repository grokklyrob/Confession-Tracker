#!/bin/sh
# Static checks from SPEC.md sections 10 and 11. Pass the built .app path to also scan the binary.
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$root"

fail() {
  echo "static-checks: $1" >&2
  exit 1
}

if grep -R -n --include='*.swift' -E '^\s*print\(' ConfessionTracker; then
  fail "print() is not allowed in app sources"
fi

if grep -R -n --include='*.swift' -E 'URLSession|URLRequest|import Network' ConfessionTracker; then
  fail "app sources must not reference the network stack"
fi

if find . -name '*.entitlements' -not -path './.git/*' | grep -q .; then
  fail "the app must not have an entitlements file"
fi

if grep -R -n -i --include='*.swift' --include='*.json' --include='*.xcstrings' --include='*.plist' \
  -e 'father of mercies' \
  -e 'sorry for my sins with all my heart' \
  -e 'freed you from your sins' \
  ConfessionTracker; then
  fail "ICEL check phrase found in sources"
fi

if [ "${1:-}" != "" ]; then
  app=$1
  if [ ! -d "$app" ]; then
    fail "app bundle not found: $app"
  fi
  if grep -R -i -l \
    -e 'father of mercies' \
    -e 'sorry for my sins with all my heart' \
    -e 'freed you from your sins' \
    "$app"; then
    fail "ICEL check phrase found in the built app"
  fi
  if strings "$app/ConfessionTracker" | grep -q 'URLSession'; then
    fail "URLSession reference found in the app binary"
  fi
fi

echo "static-checks: ok"
