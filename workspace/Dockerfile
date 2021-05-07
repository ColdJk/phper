ARG DOCKER_PHP_VERSION
ARG BASE_IMAGE_TAG_PREFIX=latest
FROM senkorl/workspace:${BASE_IMAGE_TAG_PREFIX}-${DOCKER_PHP_VERSION}

ARG DOCKER_PHP_VERSION

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# Start as root
USER root

###########################################################################
# If you're in China, or you need to change sources, will be set CHANGE_SOURCE to true in .env.
###########################################################################

ARG CHANGE_SOURCE=false
ARG UBUNTU_SOURCE=aliyun
COPY apt_sources.sh /tmp/sources.sh
RUN if [ ${CHANGE_SOURCE} = true ]; then \
    # Change application source from deb.debian.org to aliyun source
    sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list; \
    sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list; \
    sed -i 's/security-cdn.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list; \
    chmod +x /tmp/sources.sh; \
    /bin/sh -c /tmp/sources.sh; \
  fi; \
  rm -rf /tmp/sources.sh

###########################################################################
# phper non-root user:
###########################################################################

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

# always run apt update when start and after add new source list, then clean up at end.
RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    groupadd -g ${PGID} phper && \
    useradd -l -u ${PUID} -g phper -m phper -G docker_env && \
    usermod -p "*" phper -s /bin/bash && \
    apt-get install -yqq \
      apt-utils \
      #
      #--------------------------------------------------------------------------
      # Mandatory Software's Installation
      #--------------------------------------------------------------------------
      #
      # Mandatory Software's such as ("php-cli", "git", "vim", ....) are
      # installed on the base image 'laradock/workspace' image. If you want
      # to add more Software's or remove existing one, you need to edit the
      # base image (https://github.com/laradock/workspace).
      #
      # next lines are here because there is no auto build on dockerhub see https://github.com/laradock/laradock/pull/1903#issuecomment-463142846
      # Custom installation
      net-tools \
      wget \
      libzip-dev zip unzip \
      # Install the zip extension
      php${DOCKER_PHP_VERSION}-zip \
      # nasm
      nasm && \
      php -m | grep -q 'zip'

#
#--------------------------------------------------------------------------
# Optional Software's Installation
#--------------------------------------------------------------------------
#
# Optional Software's will only be installed if you set them to `true`
# in the `docker-compose.yml` before the build.
# Example:
#   - INSTALL_NODE=false
#   - ...
#

###########################################################################
# Set Timezone
###########################################################################

ARG TZ=UTC
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

###########################################################################
# User Aliases
###########################################################################

USER root

COPY ./aliases.sh /root/aliases.sh
COPY ./aliases.sh /home/phper/aliases.sh

RUN sed -i 's/\r//' /root/aliases.sh && \
    sed -i 's/\r//' /home/phper/aliases.sh && \
    chown phper:phper /home/phper/aliases.sh && \
    echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/aliases.sh" >> ~/.bashrc && \
	  echo "" >> ~/.bashrc

USER phper

RUN echo "" >> ~/.bashrc && \
    echo "# Load Custom Aliases" >> ~/.bashrc && \
    echo "source ~/aliases.sh" >> ~/.bashrc && \
	  echo "" >> ~/.bashrc

###########################################################################
# Composer:
###########################################################################

USER root

# Add the composer.json
COPY composer/composer.json /home/phper/.composer/composer.json

# Add the auth.json for magento 2 credentials
COPY composer/auth.json /home/phper/.composer/auth.json

# Make sure that ~/.composer belongs to phper
RUN chown -R phper:phper /home/phper/.composer

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc

USER phper

# Check if global install need to be ran
ARG COMPOSER_GLOBAL_INSTALL=false
ENV COMPOSER_GLOBAL_INSTALL ${COMPOSER_GLOBAL_INSTALL}

RUN if [ ${COMPOSER_GLOBAL_INSTALL} = true ]; then \
    # run the install
    composer global install \
;fi

# Check if auth file is disabled
ARG COMPOSER_AUTH=false
ENV COMPOSER_AUTH ${COMPOSER_AUTH}

RUN if [ ${COMPOSER_AUTH} = false ]; then \
    # remove the file
    rm /home/phper/.composer/auth.json \
;fi

ARG COMPOSER_REPO_PACKAGIST
ENV COMPOSER_REPO_PACKAGIST ${COMPOSER_REPO_PACKAGIST}

RUN if [ ${COMPOSER_REPO_PACKAGIST} ]; then \
    composer config -g repo.packagist composer ${COMPOSER_REPO_PACKAGIST} \
;fi

# Export composer vendor path
RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="~/.composer/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# Non-root user : PHPUnit path
###########################################################################

# add ./vendor/bin to non-root user's bashrc (needed for phpunit)
USER phper

RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="/var/www/default/vendor/bin:$PATH"' >> ~/.bashrc



## ================  php extension  ==================

###########################################################################
USER root

ARG INSTALL_BZ2=false
ARG INSTALL_GMP=false
ARG INSTALL_GNUPG=false
ARG INSTALL_SSH2=false
ARG INSTALL_SOAP=false
ARG INSTALL_XSL=false
ARG PHP_VERSION=${DOCKER_PHP_VERSION}

RUN set -eux; \
    apt-get update -yqq; \
    ###########################################################################
    # BZ2:
    ###########################################################################
    if [ ${INSTALL_BZ2} = true ]; then \

      apt-get -yqq install php${DOCKER_PHP_VERSION}-bz2; \
    fi; \
    ###########################################################################
    # GMP (GNU Multiple Precision):
    ###########################################################################
    if [ ${INSTALL_GMP} = true ]; then \
      # Install the PHP GMP extension
      apt-get -yqq install php${DOCKER_PHP_VERSION}-gmp; \
    fi; \
    ###########################################################################
    # GnuPG:
    ###########################################################################
    if [ ${INSTALL_GNUPG} = true ]; then \
        apt-get -yqq install php${DOCKER_PHP_VERSION}-gnupg; \
    fi; \
    ###########################################################################
    # SSH2:
    ###########################################################################
    if [ ${INSTALL_SSH2} = true ]; then \
      # Install the PHP SSH2 extension
      apt-get -yqq install libssh2-1-dev php${DOCKER_PHP_VERSION}-ssh2; \
    fi; \
    ###########################################################################
    # SOAP:
    ###########################################################################
    if [ ${INSTALL_SOAP} = true ]; then \
      # Install the PHP SOAP extension
      apt-get -yqq install libxml2-dev php${DOCKER_PHP_VERSION}-soap; \
    fi; \
    ###########################################################################
    # XSL:
    ###########################################################################
    if [ ${INSTALL_XSL} = true ]; then \
      # Install the PHP XSL extension
      apt-get -yqq install libxslt-dev php${DOCKER_PHP_VERSION}-xsl; \
    fi

###########################################################################

ARG INSTALL_LDAP=false
ARG INSTALL_SMB=false
ARG INSTALL_IMAP=false
ARG INSTALL_SUBVERSION=false

RUN set -eux; \
    apt-get update -yqq; \
    ###########################################################################
    # LDAP:
    ###########################################################################
    if [ ${INSTALL_LDAP} = true ]; then \
        apt-get install -yqq libldap2-dev php${DOCKER_PHP_VERSION}-ldap; \
    fi; \
    ###########################################################################
    # SMB:
    ###########################################################################
    if [ ${INSTALL_SMB} = true ]; then \
        apt-get install -yqq smbclient php-smbclient coreutils; \
    fi; \
    ###########################################################################
    # IMAP:
    ###########################################################################
    if [ ${INSTALL_IMAP} = true ]; then \
        apt-get install -yqq php${DOCKER_PHP_VERSION}-imap; \
    fi; \
    ###########################################################################
    # Subversion:
    ###########################################################################
    if [ ${INSTALL_SUBVERSION} = true ]; then \
        apt-get install -yqq subversion; \
    fi

###########################################################################
# PHP Swoole EXTENSION:
###########################################################################

COPY ./swoole-src-master.tar.gz /tmp/swoole-src.tar.gz
USER root

ARG INSTALL_SWOOLE=false

# 编译安装 可自定义参数 例如openssl支持
RUN  if [ ${INSTALL_SWOOLE} = true ]; then \
    cd / && \
    rm -rf ./tmp/swoole-src && \
    if   [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "50600" ]; then \
      curl -o ./tmp/swoole.tar.gz https://github.com/swoole/swoole-src/archive/refs/tags/v2.0.10.tar.gz -L; \
    elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70000" ]; then \
      curl -o ./tmp/swoole.tar.gz https://github.com/swoole/swoole-src/archive/refs/tags/v4.3.5.tar.gz -L; \
    elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70100" ]; then \
      curl -o ./tmp/swoole.tar.gz https://github.com/swoole/swoole-src/archive/refs/tags/v4.5.11.tar.gz -L; \
    else \
      mv /tmp/swoole-src.tar.gz /tmp/swoole.tar.gz; \
    fi; \
    tar zxvf ./tmp/swoole.tar.gz && \
    mv swoole* swoole-src && \
    cd swoole-src && \
    phpize && \
    ./configure \
    --enable-openssl \
    --enable-http2 && \
    make && make install \
    && echo "extension=swoole.so" > /etc/php/${DOCKER_PHP_VERSION}/mods-available/swoole.ini && \
    ln -s /etc/php/${DOCKER_PHP_VERSION}/mods-available/swoole.ini /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/20-swoole.ini \
    && php -m | grep -q 'swoole' \
    && echo "swoole.use_shortname = off" >> /etc/php/${DOCKER_PHP_VERSION}/cli/php.ini \
    && rm -rf /swoole-src \
;fi

###########################################################################
# PHP REDIS EXTENSION
###########################################################################

USER root

ARG INSTALL_PHPREDIS=false

RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
    apt-get update -yqq && \
    apt-get install -yqq php${DOCKER_PHP_VERSION}-redis \
;fi

###########################################################################
# PHP Memcached EXTENSION:
###########################################################################

ARG INSTALL_MEMCACHED=false

RUN if [ ${INSTALL_MEMCACHED} = true ]; then \
  apt-get -y install php${DOCKER_PHP_VERSION}-igbinary \
  && apt-get -y install php${DOCKER_PHP_VERSION}-memcached \
;fi

###########################################################################
# PHP MongoDB EXTENSION:
###########################################################################

USER root

ARG INSTALL_MONGO=false

RUN if [ ${INSTALL_MONGO} = true ]; then \
    # Install the mongodb extension
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install mongo && \
      echo "extension=mongo.so" >> /etc/php/${DOCKER_PHP_VERSION}/mods-available/mongo.ini && \
      ln -s /etc/php/${DOCKER_PHP_VERSION}/mods-available/mongo.ini /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/30-mongo.ini \
    ;fi && \
    pecl install mongodb && \
    echo "extension=mongodb.so" >> /etc/php/${DOCKER_PHP_VERSION}/mods-available/mongodb.ini && \
    ln -s /etc/php/${DOCKER_PHP_VERSION}/mods-available/mongodb.ini /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/30-mongodb.ini \
;fi

###########################################################################
# PHP AMQP EXTENSION:
###########################################################################

USER root

ARG INSTALL_AMQP=false

RUN if [ ${INSTALL_AMQP} = true ]; then \
    apt-get install librabbitmq-dev -y && \
    pecl -q install amqp && \
    echo "extension=amqp.so" >> /etc/php/${DOCKER_PHP_VERSION}/mods-available/amqp.ini && \
    ln -s /etc/php/${DOCKER_PHP_VERSION}/mods-available/amqp.ini /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/30-amqp.ini \
;fi

###########################################################################
# PHP ImageMagick EXTENSION:
###########################################################################

USER root

ARG INSTALL_IMAGEMAGICK=false
ARG IMAGEMAGICK_VERSION=latest
ENV IMAGEMAGICK_VERSION ${IMAGEMAGICK_VERSION}

RUN if [ ${INSTALL_IMAGEMAGICK} = true ]; then \
    apt-get install -y libmagickwand-dev imagemagick && \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
      apt-get install -y git && \
      cd /tmp && \
      if [ ${IMAGEMAGICK_VERSION} = "latest" ]; then \
        git clone https://github.com/Imagick/imagick; \
      else \
        git clone --branch ${IMAGEMAGICK_VERSION} https://github.com/Imagick/imagick; \
      fi && \
      cd imagick && \
      phpize && \
      ./configure && \
      make && \
      make install && \
      rm -r /tmp/imagick; \
    else \
      pecl install imagick; \
    fi && \
    echo "extension=imagick.so" >> /etc/php/${DOCKER_PHP_VERSION}/mods-available/imagick.ini && \
    ln -s /etc/php/${DOCKER_PHP_VERSION}/mods-available/imagick.ini /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/20-imagick.ini && \
    php -m | grep -q 'imagick' \
;fi

###########################################################################
# PHP AST EXTENSION
###########################################################################

ARG INSTALL_AST=false
ARG AST_VERSION=1.0.10
ENV AST_VERSION ${AST_VERSION}

RUN if [ ${INSTALL_AST} = true ]; then \
    # AST extension requires PHP 7.0.0 or newer
    if [ $(php -r "echo PHP_MAJOR_VERSION;") != "5" ]; then \
        # Install AST extension
        printf "\n" | pecl -q install ast-${AST_VERSION} && \
        echo "extension=ast.so" >> /etc/php/${DOCKER_PHP_VERSION}/mods-available/ast.ini && \
        phpenmod -v ${DOCKER_PHP_VERSION} -s cli ast \
    ;fi \
;fi

###########################################################################
# PHP xDebug EXTENSION:
###########################################################################

USER root

ARG INSTALL_XDEBUG=false

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
  # Install the xdebug extension
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
    pecl install xdebug-3.0.0; \
  else \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install xdebug-2.5.5; \
    else \
      if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
        pecl install xdebug-2.9.0; \
      else \
        if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && [ $(php -r "echo PHP_MINOR_VERSION;") = "1" ]; then \
          pecl install xdebug-2.9.8; \
        else \
          if [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ]; then \
            pecl install xdebug-2.9.8; \
          else \
            #pecl install xdebug; \
            echo "xDebug 3 required, not supported."; \
          fi \
        fi \
      fi \
    fi \
  fi && \
  echo "zend_extension=xdebug.so" >> /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/20-xdebug.ini \
;fi

# ADD for REMOTE debugging
COPY ./xdebug.ini /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini

RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
  sed -i "s/xdebug.remote_host=/xdebug.client_host=/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_connect_back=0/xdebug.discover_client_host=false/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_port=9000/xdebug.client_port=9003/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
  sed -i "s/xdebug.profiler_enable=0/; xdebug.profiler_enable=0/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
  sed -i "s/xdebug.profiler_output_dir=/xdebug.output_dir=/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_mode=req/; xdebug.remote_mode=req/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_autostart=0/xdebug.start_with_request=yes/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_enable=0/xdebug.mode=debug/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini \
;else \
  sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_enable=0/xdebug.remote_enable=1/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini \
;fi
RUN sed -i "s/xdebug.cli_color=0/xdebug.cli_color=1/" /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/xdebug.ini

###########################################################################
# PHP V8JS EXTENSION:
###########################################################################

USER root

ARG INSTALL_V8JS=false

RUN set -xe; \
  if [ ${INSTALL_V8JS} = true ]; then \
    add-apt-repository -y ppa:pinepain/libv8-archived \
    && apt-get update -yqq \
    && apt-get install -y libv8-5.4 && \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install v8js-0.6.4; \
    else \
      pecl install v8js; \
    fi \
    && echo "extension=v8js.so" >> /etc/php/${DOCKER_PHP_VERSION}/cli/php.ini \
    && php -m | grep -q 'v8js' \
  ;fi

###########################################################################
# Laravel Envoy:
###########################################################################

USER phper

ARG INSTALL_LARAVEL_ENVOY=false

RUN if [ ${INSTALL_LARAVEL_ENVOY} = true ]; then \
    # Install the Laravel Envoy
    composer global require laravel/envoy \
;fi

###########################################################################
# Laravel Installer:
###########################################################################

USER phper

ARG INSTALL_LARAVEL_INSTALLER=false

RUN if [ ${INSTALL_LARAVEL_INSTALLER} = true ]; then \
    # Install the Laravel Installer
	composer global require "laravel/installer" \
;fi

USER root

ARG COMPOSER_REPO_PACKAGIST
ENV COMPOSER_REPO_PACKAGIST ${COMPOSER_REPO_PACKAGIST}

RUN if [ ${COMPOSER_REPO_PACKAGIST} ]; then \
    composer config -g repo.packagist composer ${COMPOSER_REPO_PACKAGIST} \
;fi



## =============  other software  =================

###########################################################################
# Crontab
###########################################################################

USER root

COPY ./crontab /etc/cron.d

RUN chmod -R 644 /etc/cron.d

###########################################################################
USER root

ARG INSTALL_MYSQL_CLIENT=false
ARG INSTALL_PING=false
ARG INSTALL_SSHPASS=false
ARG INSTALL_DOCKER_CLIENT=false

RUN set -eux; \
  ###########################################################################
  # MySQL Client:
  ###########################################################################
  if [ ${INSTALL_MYSQL_CLIENT} = true ]; then \
    apt-get -yqq install mysql-client; \
  fi; \
  ###########################################################################
  # ping:
  ###########################################################################
  if [ ${INSTALL_PING} = true ]; then \
    apt-get -yqq install inetutils-ping; \
  fi; \
  ###########################################################################
  # sshpass:
  ###########################################################################
  if [ ${INSTALL_SSHPASS} = true ]; then \
    apt-get -yqq install sshpass; \
  fi; \
  ###########################################################################
  # Docker Client:
  ###########################################################################
  if [ ${INSTALL_DOCKER_CLIENT} = true ]; then \
    curl -sS https://download.docker.com/linux/static/stable/x86_64/docker-20.10.3.tgz -o /tmp/docker.tar.gz; \
    tar -xzf /tmp/docker.tar.gz -C /tmp/; \
    cp /tmp/docker/docker* /usr/local/bin; \
    chmod +x /usr/local/bin/docker*; \
  fi

###########################################################################
# fswatch
###########################################################################

ARG INSTALL_FSWATCH=false

RUN if [ ${INSTALL_FSWATCH} = true ]; then \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 47FE03C1 \
    && add-apt-repository -y ppa:hadret/fswatch \
    || apt-get update -yqq \
    && apt-get -y install fswatch \
;fi

###########################################################################
# Node / NVM:
###########################################################################

# Check if NVM needs to be installed
ARG NODE_VERSION=node
ENV NODE_VERSION ${NODE_VERSION}
ARG INSTALL_NODE=false
ARG INSTALL_NPM_GULP=false
ARG INSTALL_NPM_BOWER=false
ARG INSTALL_NPM_VUE_CLI=false
ARG INSTALL_NPM_ANGULAR_CLI=false
ARG NPM_REGISTRY
ENV NPM_REGISTRY ${NPM_REGISTRY}
ARG NPM_FETCH_RETRIES
ENV NPM_FETCH_RETRIES ${NPM_FETCH_RETRIES}
ARG NPM_FETCH_RETRY_FACTOR
ENV NPM_FETCH_RETRY_FACTOR ${NPM_FETCH_RETRY_FACTOR}
ARG NPM_FETCH_RETRY_MINTIMEOUT
ENV NPM_FETCH_RETRY_MINTIMEOUT ${NPM_FETCH_RETRY_MINTIMEOUT}
ARG NPM_FETCH_RETRY_MAXTIMEOUT
ENV NPM_FETCH_RETRY_MAXTIMEOUT ${NPM_FETCH_RETRY_MAXTIMEOUT}
ENV NVM_DIR /home/phper/.nvm
ARG NVM_NODEJS_ORG_MIRROR
ENV NVM_NODEJS_ORG_MIRROR ${NVM_NODEJS_ORG_MIRROR}

COPY ./nvm_install.sh /tmp/nvm_install.sh

RUN if [ ${INSTALL_NODE} = true ]; then \
    # Install nvm (A Node Version Manager)
        mkdir -p $NVM_DIR \
        && bash /tmp/nvm_install.sh \
        && . $NVM_DIR/nvm.sh \
        && nvm install ${NODE_VERSION} \
        && nvm use ${NODE_VERSION} \
        && nvm alias ${NODE_VERSION} \
        && npm config set fetch-retries ${NPM_FETCH_RETRIES} \
        && npm config set fetch-retry-factor ${NPM_FETCH_RETRY_FACTOR} \
        && npm config set fetch-retry-mintimeout ${NPM_FETCH_RETRY_MINTIMEOUT} \
        && npm config set fetch-retry-maxtimeout ${NPM_FETCH_RETRY_MAXTIMEOUT} \
        && if [ ${NPM_REGISTRY} ]; then \
        npm config set registry ${NPM_REGISTRY} \
        ;fi \
        && if [ ${INSTALL_NPM_GULP} = true ]; then \
        npm install -g gulp \
        ;fi \
        && if [ ${INSTALL_NPM_BOWER} = true ]; then \
        npm install -g bower \
        ;fi \
        && if [ ${INSTALL_NPM_VUE_CLI} = true ]; then \
        npm install -g @vue/cli \
        ;fi \
        && if [ ${INSTALL_NPM_ANGULAR_CLI} = true ]; then \
        npm install -g @angular/cli \
        ;fi \
        && ln -s `npm bin --global` /home/phper/.node-bin \
;fi

# Wouldn't execute when added to the RUN statement in the above block
# Source NVM when loading bash since ~/.profile isn't loaded on non-login shell
RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
;fi

# Add NVM binaries to root's .bashrc
USER root

RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="/home/phper/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc && \
    if [ ${NPM_REGISTRY} ]; then \
        . ~/.bashrc && npm config set registry ${NPM_REGISTRY} \
    ;fi \
;fi

# Add PATH for node
ENV PATH $PATH:/home/phper/.node-bin

# Make it so the node modules can be executed with 'docker-compose exec'
# We'll create symbolic links into '/usr/local/bin'.
RUN if [ ${INSTALL_NODE} = true ]; then \
    find $NVM_DIR -type f -name node -exec ln -s {} /usr/local/bin/node \; && \
    NODE_MODS_DIR="$NVM_DIR/versions/node/$(node -v)/lib/node_modules" && \
    ln -s $NODE_MODS_DIR/bower/bin/bower /usr/local/bin/bower && \
    ln -s $NODE_MODS_DIR/gulp/bin/gulp.js /usr/local/bin/gulp && \
    ln -s $NODE_MODS_DIR/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s $NODE_MODS_DIR/npm/bin/npx-cli.js /usr/local/bin/npx && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue /usr/local/bin/vue && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue-init /usr/local/bin/vue-init && \
    ln -s $NODE_MODS_DIR/vue-cli/bin/vue-list /usr/local/bin/vue-list \
;fi

# Mount .npmrc into home folder
COPY ./.npmrc /root/.npmrc
COPY ./.npmrc /home/phper/.npmrc

###########################################################################
# PNPM:
###########################################################################

USER phper

ARG INSTALL_PNPM=false

RUN if [ ${INSTALL_PNPM} = true ]; then \
    npx pnpm add -g pnpm \
;fi

###########################################################################
# YARN:
###########################################################################

USER phper

ARG INSTALL_YARN=false
ARG YARN_VERSION=latest
ENV YARN_VERSION ${YARN_VERSION}

RUN if [ ${INSTALL_YARN} = true ]; then \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    if [ ${YARN_VERSION} = "latest" ]; then \
        curl -o- -L https://yarnpkg.com/install.sh | bash; \
    else \
        curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version ${YARN_VERSION}; \
    fi && \
    echo "" >> ~/.bashrc && \
    echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> ~/.bashrc \
;fi

# Add YARN binaries to root's .bashrc
USER root

RUN if [ ${INSTALL_YARN} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export YARN_DIR="/home/phper/.yarn"' >> ~/.bashrc && \
    echo 'export PATH="$YARN_DIR/bin:$PATH"' >> ~/.bashrc \
;fi

# Add PATH for YARN
ENV PATH $PATH:/home/phper/.yarn/bin

###########################################################################
# Blackfire:
###########################################################################

ARG INSTALL_BLACKFIRE=false
ARG BLACKFIRE_CLIENT_ID
ENV BLACKFIRE_CLIENT_ID ${BLACKFIRE_CLIENT_ID}
ARG BLACKFIRE_CLIENT_TOKEN
ENV BLACKFIRE_CLIENT_TOKEN ${BLACKFIRE_CLIENT_TOKEN}

RUN if [ ${INSTALL_XDEBUG} = false -a ${INSTALL_BLACKFIRE} = true ]; then \
    curl -L https://packages.blackfire.io/gpg.key | apt-key add - && \
    echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list && \
    apt-get update -yqq && \
    apt-get install blackfire-agent \
;fi

###########################################################################
# PYTHON2:
###########################################################################

USER root

COPY ./pip.ini /tmp/pip.ini

ARG INSTALL_PYTHON=false

RUN if [ ${INSTALL_PYTHON} = true ]; then \
  apt-get -y install python python-dev build-essential  \
  # 部分 `apt` 镜像源已经没有2版本的 `python-pip` 包，所以改为下面方式安装
  && curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && python get-pip.py && rm get-pip.py \
  && python -m pip install --upgrade pip  \
  && python -m pip install virtualenv \
  && mkdir ~/pip && mv -f /tmp/pip.ini ~/pip/pip.ini && rm -rf /tmp/pip.ini \
;fi

###########################################################################
# PYTHON3:
###########################################################################

ARG INSTALL_PYTHON3=false

RUN if [ ${INSTALL_PYTHON3} = true ]; then \
  apt-get -y install python3 python3-pip python3-dev build-essential  \
  && python3 -m pip install --upgrade --force-reinstall pip  \
  && python3 -m pip install --upgrade virtualenv \
;fi

###########################################################################
# POWERLINE:
###########################################################################

USER root
ARG INSTALL_POWERLINE=false

RUN if [ ${INSTALL_POWERLINE} = true ]; then \
    if [ ${INSTALL_PYTHON} = true ]; then \
    python -m pip install --upgrade powerline-status && \
    echo "" >> /etc/bash.bashrc && \
    echo ". /usr/local/lib/python2.7/dist-packages/powerline/bindings/bash/powerline.sh" >> /etc/bash.bashrc \
  ;fi \
;fi

###########################################################################
# SUPERVISOR:
###########################################################################
USER root

ARG INSTALL_SUPERVISOR=false

RUN if [ ${INSTALL_SUPERVISOR} = true ]; then \
    if [ ${INSTALL_PYTHON} = true ]; then \
    python -m pip install --upgrade supervisor && \
    echo_supervisord_conf > /etc/supervisord.conf && \
    sed -i 's/\;\[include\]/\[include\]/g' /etc/supervisord.conf && \
    sed -i 's/\;files\s.*/files = supervisord.d\/*.conf/g' /etc/supervisord.conf \
  ;fi \
;fi

###########################################################################
# ssh:
###########################################################################

ARG INSTALL_WORKSPACE_SSH=false

COPY rsa/insecure_id_rsa /tmp/id_rsa
COPY rsa/insecure_id_rsa.pub /tmp/id_rsa.pub

RUN if [ ${INSTALL_WORKSPACE_SSH} = true ]; then \
    rm -f /etc/service/sshd/down && \
    cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys \
        && cat /tmp/id_rsa.pub >> /root/.ssh/id_rsa.pub \
        && cat /tmp/id_rsa >> /root/.ssh/id_rsa \
        && rm -f /tmp/id_rsa* \
        && chmod 644 /root/.ssh/authorized_keys /root/.ssh/id_rsa.pub \
    && chmod 400 /root/.ssh/id_rsa \
    && cp -rf /root/.ssh /home/phper \
    && chown -R phper:phper /home/phper/.ssh \
;fi

###########################################################################
# Linuxbrew:
###########################################################################

USER root

ARG INSTALL_LINUXBREW=false

RUN if [ ${INSTALL_LINUXBREW} = true ]; then \
    # Preparation
    apt-get upgrade -y && \
    apt-get install -y build-essential make cmake scons curl git \
      ruby autoconf automake autoconf-archive \
      gettext libtool flex bison \
      libbz2-dev libcurl4-openssl-dev \
      libexpat-dev libncurses-dev && \
    # Install the Linuxbrew
    git clone --depth=1 https://github.com/Homebrew/linuxbrew.git ~/.linuxbrew && \
    echo "" >> ~/.bashrc && \
    echo 'export PKG_CONFIG_PATH"=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib64/pkgconfig:/usr/share/pkgconfig:$PKG_CONFIG_PATH"' >> ~/.bashrc && \
    # Setup linuxbrew
    echo 'export LINUXBREWHOME="$HOME/.linuxbrew"' >> ~/.bashrc && \
    echo 'export PATH="$LINUXBREWHOME/bin:$PATH"' >> ~/.bashrc && \
    echo 'export MANPATH="$LINUXBREWHOME/man:$MANPATH"' >> ~/.bashrc && \
    echo 'export PKG_CONFIG_PATH="$LINUXBREWHOME/lib64/pkgconfig:$LINUXBREWHOME/lib/pkgconfig:$PKG_CONFIG_PATH"' >> ~/.bashrc && \
    echo 'export LD_LIBRARY_PATH="$LINUXBREWHOME/lib64:$LINUXBREWHOME/lib:$LD_LIBRARY_PATH"' >> ~/.bashrc \
;fi


###########################################################################
# Protoc:
###########################################################################

ARG INSTALL_PROTOC=false
ARG PROTOC_VERSION

RUN if [ ${INSTALL_PROTOC} = true ]; then \
  if [ ${PROTOC_VERSION} = "latest" ]; then \
    REAL_PROTOC_VERSION=$(curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases/latest | \
      sed -nr 's/.*"tag_name":\s?"v(.+?)".*/\1/p'); \
  else \
    REAL_PROTOC_VERSION=${PROTOC_VERSION}; \
  fi && \
  PROTOC_ZIP=protoc-${REAL_PROTOC_VERSION}-linux-x86_64.zip; \
  curl -L -o /tmp/protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v${REAL_PROTOC_VERSION}/${PROTOC_ZIP} && \
  unzip -q -o /tmp/protoc.zip -d /usr/local bin/protoc && \
  unzip -q -o /tmp/protoc.zip -d /usr/local 'include/*' && \
  rm -f /tmp/protoc.zip && \
  chmod +x /usr/local/bin/protoc && \
  chmod -R +r /usr/local/include/google \
;fi

###########################################################################
# Check PHP version:
###########################################################################

RUN set -xe; php -v | head -n 1 | grep -q "PHP ${DOCKER_PHP_VERSION}."


###########################################################################
# Oh My ZSH!
###########################################################################

USER root

ARG SHELL_OH_MY_ZSH=false
RUN if [ ${SHELL_OH_MY_ZSH} = true ]; then \
    apt install -y zsh \
;fi

ARG SHELL_OH_MY_ZSH_AUTOSUGESTIONS=false
ARG SHELL_OH_MY_ZSH_ALIASES=false

USER phper
RUN if [ ${SHELL_OH_MY_ZSH} = true ]; then \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --keep-zshrc" && \
    sed -i -r 's/^plugins=\(.*?\)$/plugins=(laravel5)/' /home/phper/.zshrc && \
    echo '\n\
bindkey "^[OB" down-line-or-search\n\
bindkey "^[OC" forward-char\n\
bindkey "^[OD" backward-char\n\
bindkey "^[OF" end-of-line\n\
bindkey "^[OH" beginning-of-line\n\
bindkey "^[[1~" beginning-of-line\n\
bindkey "^[[3~" delete-char\n\
bindkey "^[[4~" end-of-line\n\
bindkey "^[[5~" up-line-or-history\n\
bindkey "^[[6~" down-line-or-history\n\
bindkey "^?" backward-delete-char\n' >> /home/phper/.zshrc && \
  if [ ${SHELL_OH_MY_ZSH_AUTOSUGESTIONS} = true ]; then \
    sh -c "git clone https://github.com/zsh-users/zsh-autosuggestions /home/phper/.oh-my-zsh/custom/plugins/zsh-autosuggestions" && \
    sed -i 's~plugins=(~plugins=(zsh-autosuggestions ~g' /home/phper/.zshrc && \
    sed -i '1iZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20' /home/phper/.zshrc && \
    sed -i '1iZSH_AUTOSUGGEST_STRATEGY=(history completion)' /home/phper/.zshrc && \
    sed -i '1iZSH_AUTOSUGGEST_USE_ASYNC=1' /home/phper/.zshrc && \
    sed -i '1iTERM=xterm-256color' /home/phper/.zshrc \
  ;fi && \
  if [ ${SHELL_OH_MY_ZSH_ALIASES} = true ]; then \
    echo "" >> /home/phper/.zshrc && \
    echo "# Load Custom Aliases" >> /home/phper/.zshrc && \
    echo "source /home/phper/aliases.sh" >> /home/phper/.zshrc && \
    echo "" >> /home/phper/.zshrc \
  ;fi \
;fi

USER root

###########################################################################
# ZSH User Aliases
###########################################################################

USER root

COPY ./aliases.sh /root/aliases.sh
COPY ./aliases.sh /home/phper/aliases.sh

RUN if [ ${SHELL_OH_MY_ZSH} = true ]; then \
    sed -i 's/\r//' /root/aliases.sh && \
    sed -i 's/\r//' /home/phper/aliases.sh && \
    chown phper:phper /home/phper/aliases.sh && \
    echo "" >> ~/.zshrc && \
    echo "# Load Custom Aliases" >> ~/.zshrc && \
    echo "source ~/aliases.sh" >> ~/.zshrc && \
	  echo "" >> ~/.zshrc \
;fi

USER phper

RUN if [ ${SHELL_OH_MY_ZSH} = true ]; then \
    echo "" >> ~/.zshrc && \
    echo "# Load Custom Aliases" >> ~/.zshrc && \
    echo "source ~/aliases.sh" >> ~/.zshrc && \
	  echo "" >> ~/.zshrc \
;fi

USER root

###########################################################################
# zookeeper
###########################################################################
ARG INSTALL_ZOOKEEPER=false

RUN set -eux; \
    if [ ${INSTALL_ZOOKEEPER} = true ]; then \
    apt install -yqq libzookeeper-mt-dev; \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
      curl -L -o /tmp/php-zookeeper.tar.gz https://github.com/php-zookeeper/php-zookeeper/archive/master.tar.gz; \
      mkdir -p /tmp/php-zookeeper; \
      tar -C /tmp/php-zookeeper -zxvf /tmp/php-zookeeper.tar.gz --strip 1; \
      cd /tmp/php-zookeeper; \
      phpize && ./configure && make && make install;\
    else \
      if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install zookeeper-0.5.0; \
      else \
        pecl install zookeeper-0.7.2; \
      fi; \
    fi; \
    echo "extension=zookeeper.so" >> /etc/php/${DOCKER_PHP_VERSION}/mods-available/zookeeper.ini; \
    ln -s /etc/php/${DOCKER_PHP_VERSION}/mods-available/zookeeper.ini /etc/php/${DOCKER_PHP_VERSION}/cli/conf.d/30-zookeeper.ini; \
    php -m | grep -q 'zookeeper'; \
    fi

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# Set default work directory
WORKDIR /var/www
