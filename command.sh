#!/usr/bin/env bash

print_style () {

    if [ "$2" == "info" ] ; then
        COLOR="96m"
    elif [ "$2" == "success" ] ; then
        COLOR="92m"
    elif [ "$2" == "warning" ] ; then
        COLOR="93m"
    elif [ "$2" == "danger" ] ; then
        COLOR="91m"
    else #default color
        COLOR="0m"
    fi

    STARTCOLOR="\e[$COLOR"
    ENDCOLOR="\e[0m"

    printf "$STARTCOLOR%b$ENDCOLOR" "$1"
}

display_options () {
    printf "Available options:\n";
    print_style "   build [services]" "info"; printf "\t Build containers.\n"
    print_style "   up [services]" "info"; printf "\t Runs docker compose.\n"
    print_style "   down" "info"; printf "\t\t\t Down containers.\n"
    print_style "   start [services]" "info"; printf "\t Start Docker Compose.\n"
    print_style "   restart [services]" "info"; printf "\t Restart Docker Compose.\n"
    print_style "   stop [services]" "info"; printf "\t Stop containers.\n"
    print_style "   ps" "info"; printf "\t\t\t Ps containers.\n"
    print_style "   log [services]" "info"; printf "\t Logs container.\n"
    print_style "   bash [service]" "info"; printf "\t Exec Docker Compose with bash.\n"
    print_style "   sh [service]" "info"; printf "\t\t Exec Docker Compose with sh.\n"
    print_style "   l" "info"; printf "\t\t\t Up basic containers.\n"
    print_style "   elk" "info"; printf "\t\t\t Up elk containers.\n"
    print_style "   um" "info"; printf "\t\t\t Up mysql containers.\n"
    print_style "   sm" "info"; printf "\t\t\t Stop mysql containers.\n"
    print_style "   uw" "info"; printf "\t\t\t Up workspace containers.\n"
    print_style "   sw" "info"; printf "\t\t\t Stop workspace containers.\n"
    print_style "   user" "info"; printf "\t\t\t Open bash on the workspace with user phper.\n"
    print_style "   root" "info"; printf "\t\t\t Open bash on the workspace with root.\n"
}

if [[ $# -eq 0 ]] ; then
    print_style "Missing arguments.\n" "danger"
    display_options
    exit 1
fi

if [ "$1" == "up" ] ; then
    print_style "Initializing Docker Compose\n" "info"
    shift # removing first argument
    docker-compose up -d ${@}

elif [ "$1" == "start" ]; then
    print_style "Starting Docker Compose\n" "info"
    docker-compose start

elif [ "$1" == "build" ] ; then
    print_style "Building Docker Compose\n" "info"
    shift # removing first argument
    docker-compose build ${@}

elif [ "$1" == "stop" ]; then
    print_style "Stopping Docker Compose\n" "warning"
    docker-compose stop

elif [ "$1" == "down" ]; then
    print_style "Downing Docker Compose\n" "warning"
    docker-compose down

elif [ "$1" == "restart" ]; then
    print_style "Restarting Docker Compose\n" "info"
    shift
    docker-compose restart ${@}

elif [ "$1" == "bash" ]; then
    shift
    print_style "Execing Docker Compose\n" "info"
    docker-compose exec $1 bash

elif [ "$1" == "sh" ]; then
    shift
    print_style "Execing Docker Compose\n" "info"
    docker-compose exec $1 sh

elif [ "$1" == "ps" ]; then
    shift
    print_style "Ps containers top\n" "info"
    docker-compose ps

elif [ "$1" == "log" ]; then
    shift
    print_style "Print logs\n" "info"
    docker-compose logs $1


# 容器操作
elif [ "$1" == "user" ]; then
    print_style "Execing workspace with phper user\n" "info"
    docker-compose exec --user=phper workspace bash

elif [ "$1" == "root" ]; then
    print_style "Execing workspace with root user\n" "info"
    docker-compose exec workspace bash
elif [ "$1" == "mu" ]; then
    print_style "Uping mysql container\n" "warning"
    docker-compose up -d mysql

elif [ "$1" == "ms" ]; then
    print_style "Stoping mysql container\n" "warning"
    docker-compose stop mysql

elif [ "$1" == "wu" ]; then
    print_style "Uping workspace container\n" "warning"
    docker-compose up -d workspace

elif [ "$1" == "ws" ]; then
    print_style "Stoping workspace container\n" "warning"
    docker-compose stop workspace


# 套餐容器
elif [ "$1" == "elk" ]; then
    print_style "Uping elk containers\n" "info"
    docker-compose up -d elasticsearch kibana

elif [ "$1" == "elks" ]; then
    print_style "Stoping elk containers\n" "info"
    docker-compose stop elasticsearch kibana

elif [ "$1" == "l" ]; then
    print_style "Uping redis mysql php-worker php-fpm nginx phpmyadmin\n" "info"
    docker-compose up -d redis mysql php-worker php-fpm nginx phpmyadmin

elif [ "$1" == "mo" ]; then
    print_style "Uping redis mysql php-worker php-fpm nginx phpmyadmin\n" "info"
    docker-compose up -d mongo

elif [ "$1" == "mos" ]; then
    print_style "Uping redis mysql php-worker php-fpm nginx phpmyadmin\n" "info"
    docker-compose up -d mongo

elif [ "$1" == "ls" ]; then
    print_style "Stoping redis mysql php-worker php-fpm nginx phpmyadmin\n" "info"
    docker-compose up -d redis mariadb php-worker php-fpm nginx phpmyadmin

elif [ "$1" == "ka" ]; then
    print_style "Uping zookeeper kafka\n" "info"
    docker-compose up -d zookeeper kafka

elif [ "$1" == "kas" ]; then
    print_style "Stoping zookeeper kafka\n" "info"
    docker-compose stop zookeeper kafka
else
    print_style "Invalid arguments.\n" "danger"
    display_options
    exit 1
fi
