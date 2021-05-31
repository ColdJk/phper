#!/usr/bin/env bash

cd `dirname $0`
wwwDir=$(cd ./../phper_code/www;pwd)
ngConfDir=$(cd ./nginx/sites;pwd)
echo $wwwDir
echo $ngConfDir

# 下载项目移至web服务器的站点目录下
if [[ ! -d "${wwwDir}/phpRedisAdmin" ]]; then
    git clone -b master https://github.com/erikdubbelboer/phpRedisAdmin.git ${wwwDir}/phpRedisAdmin
fi
# composer install
cd ${wwwDir}/phpRedisAdmin && composer install
# 修改phpRedisAdmin配置
if [[ ! -d "${wwwDir}/phpRedisAdmin/includes/config.sample.inc.php" ]]; then
    cp ${wwwDir}/phpRedisAdmin/includes/config.sample.inc.php ${wwwDir}/phpRedisAdmin/includes/config.inc.php && \
    sed -i 's/127.0.0.1/redis/' ${wwwDir}/phpRedisAdmin/includes/config.inc.php
fi


# nginx站点配置
if [[ ! -d "${ngConfDir}/phpredisadmin.conf" ]]; then
    cp ${ngConfDir}/phpredisadmin.conf.example ${ngConfDir}/phpredisadmin.conf
fi