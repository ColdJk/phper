#!/usr/bin/env bash

# 创建日志目录
function createLogDirs()
{
  logPath="./logs/php_worker"
  if [ ! -d "$logPath" ]; then
    mkdir -p "$logPath"
    echo "$WHITE make log dir $TAILS"
  fi

  appLogDirs=('hyperf_service')
  for i in ${appLogDirs[@]}
  do
    appLogPath="${logPath}/${i}"
    if [ ! -d "$appLogPath" ]; then
      mkdir -p "$appLogPath"
      echo "$WHITE make app log dir: $appLogPath $TAILS"
    fi
  done

  hyperfServiceRuntimeLogPath="${logPath}/hyperf_service/runtime"
  if [ ! -d "$hyperfServiceRuntimeLogPath" ]; then
    mkdir -p "$hyperfServiceRuntimeLogPath"
    stderr="$hyperfServiceRuntimeLogPath/stderr.log"
    stdout="$hyperfServiceRuntimeLogPath/stdout.log"
    touch "$stderr"
    touch "$stdout"
    echo "$WHITE make hyperf_service runtime log dir: $hyperfServiceRuntimeLogPath $TAILS"
  fi

}

createLogDirs "$1"

