#!/usr/bin/env bash
set -euxo pipefail

echo 'Sourcing lib/init.sh...'
source lib/init.sh
echo 'Imported init.sh.'

echo 'Importing console...'
import console
echo 'Imported console.'

echo 'Importing http...'
import http
echo 'Imported http.'

echo 'Done.'
