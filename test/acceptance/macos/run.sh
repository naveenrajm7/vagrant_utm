#!/bin/bash
set -e

cd "$(dirname "$0")"

GUEST_PATH="/Users/vagrant/${PWD#/Users/*/}"

echo "==> Starting VM..."
vagrant up --provider=utm

echo "==> Verifying SSH..."
vagrant ssh -c 'uname -a'

echo "==> Verifying Homebrew..."
vagrant ssh -c 'brew --version'

echo "==> Verifying symlinked path..."
vagrant ssh -c "test -f ${GUEST_PATH}/Vagrantfile"

echo "==> Verifying bidirectional sync..."
rm -f README.md
vagrant ssh -c "echo '# Test' > ${GUEST_PATH}/README.md"
test -f README.md
rm -f README.md

echo "==> ALL TESTS PASSED"

vagrant destroy -f
