#!/usr/bin/env bash

# `hyperf` 应用名称集合
appLogDirs=('hyperf-skeleton')

# 创建日志目录
function createSupervisorLogDirs()
{
  logPath="./logs/php_worker"
  if [ ! -d "$logPath" ]; then
    mkdir -p "$logPath"
    echo "$WHITE make php_worker log dir $TAILS"
  fi

  for i in ${appLogDirs[@]}
  do
    appLogPath="${logPath}/${i}"
    if [ ! -d "$appLogPath/runtime" ]; then
      mkdir -p "${appLogPath}"
      mkdir -p "${appLogPath}/runtime"
      stderr="${appLogPath}/runtime/stderr.log"
      stdout="${appLogPath}/runtime/stdout.log"
      touch "$stderr"
      touch "$stdout"
      echo "$WHITE make app runtime log dir: $appLogPath $TAILS"
    fi
  done
}


createSupervisorLogDirs "$1"

