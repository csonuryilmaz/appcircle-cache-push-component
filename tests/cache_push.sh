#!/usr/bin/env bash

set -o nounset
set -o errexit

testApp="https://github.com/csonuryilmaz/TextPad.git"
export GRADLE_OPTS="-Dorg.gradle.daemon=false"

# Workflow step input variables (component.yml>inputs)
export AC_CACHE_INCLUDED_PATHS="foo:local.properties:.gradle:\$HOME/.gradle:\$HOME/bar"
#AC_CACHE_INCLUDED_PATHS="local.properties:.gradle:\$HOME/.gradle:/foo::/:bar"
export AC_CACHE_EXCLUDED_PATHS="\$HOME/.gradle/caches/*.lock"
export AC_REPOSITORY_DIR="$HOME/app/workflow_data/tjrdzp35.isa/_appcircle_temp/Repository"
export AC_CACHE_LABEL="master/app-deps"

mkdir -p $AC_REPOSITORY_DIR
if [ ! "$(ls -A $AC_REPOSITORY_DIR)" ]; then 
  rm -rf $HOME/.gradle
  git clone $testApp $AC_REPOSITORY_DIR
fi

if [ ! -f "$AC_REPOSITORY_DIR/local.properties" ]; then
  echo "sdk.dir=/home/onur/Android/Sdk" > $AC_REPOSITORY_DIR/local.properties
fi

if [ ! -d "$AC_REPOSITORY_DIR/app/build" ]; then
  cwd=$(pwd)
  cd $AC_REPOSITORY_DIR
  chmod +x ./gradlew && ./gradlew --build-cache app:assembleDebug
  cd $cwd
fi

if [ ! -L "/setup" ]; then
  sudo ln -sf $HOME /setup
fi

echo ""
echo "@@[section:begin] Step started: Cache Push"
ruby main.rb
echo "@@[section:end] Step completed: Cache Push"
