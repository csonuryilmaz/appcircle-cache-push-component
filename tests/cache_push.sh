#!/usr/bin/env bash

set -o nounset
set -o errexit

testApp="https://github.com/csonuryilmaz/TextPad.git"

export AC_CACHE_INCLUDED_PATHS="local.properties:.gradle:$HOME/.gradle"
export AC_CACHE_EXCLUDED_PATHS=""
export AC_REPOSITORY_DIR="$HOME/app/workflow_data/tjrdzp35.isa/_appcircle_temp/Repository"

mkdir -p $AC_REPOSITORY_DIR
[ "$(ls -A ${AC_REPOSITORY_DIR})" ] || git clone $testApp $AC_REPOSITORY_DIR

echo "@@[section:begin] Step started: Cache Pull"
ruby main.rb
echo "@@[section:end] Step completed: Cache Pull"
