#!/usr/bin/env bash

set -o nounset
set -o errexit

testApp="https://github.com/csonuryilmaz/TextPad.git"
export GRADLE_OPTS="-Dorg.gradle.daemon=false"

# Workflow step input variables (component.yml>inputs)
export AC_CACHE_INCLUDED_PATHS='foo:local.properties:.gradle/:~/.gradle/:~/bar:app/build/'
#AC_CACHE_INCLUDED_PATHS="local.properties:.gradle:\$HOME/.gradle:/foo::/:bar"
export AC_CACHE_EXCLUDED_PATHS='~/.gradle/caches/*.lock:**/*.apk:**/apk/*:**/logs/*'
export AC_REPOSITORY_DIR="$HOME/app/workflow_data/tjrdzp35.isa/_appcircle_temp/Repository"
#export AC_REPOSITORY_DIR=""
export AC_CACHE_LABEL="8a7719b1-05fb-41c3-96e7-c764fdb036e1/master/app-deps"
export AC_TOKEN_ID="x"
export ASPNETCORE_CALLBACK_URL="https://dev-api.appcircle.io/build/v1/callback"
export AC_OUTPUT_DIR="$HOME/Volumes/agent-disk/agent/workflow_data/fanby1hu.tmd/AC_OUTPUT_DIR"

if [ ! -z $AC_OUTPUT_DIR ]; then 
  mkdir -p $AC_OUTPUT_DIR
fi
rm -rf $AC_OUTPUT_DIR/*

if [ ! -z $AC_REPOSITORY_DIR ]; then 
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
fi

if [ ! -L "/setup" ]; then
  sudo ln -sf $HOME /setup
fi

START_TIME=$SECONDS
echo ""
echo "@@[section:begin] Step started: Cache Push"
ruby main.rb
#rdebug-ide main.rb
echo "@@[section:end] Step completed: Cache Push"
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "took $ELAPSED_TIME s"
