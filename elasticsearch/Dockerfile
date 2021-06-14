ARG ELK_VERSION
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELK_VERSION}

# ADD ./tmp/elasticsearch-analysis-ik-7.4.1.zip /usr/share/elasticsearch/plugins/analysis-ik

# 安装analysis-ik插件（使用add会导致启动失败，具体原因未排查到）
ARG ELK_VERSION
COPY plugins/elasticsearch-analysis-ik-${ELK_VERSION} /usr/share/elasticsearch/plugins/analysis-ik
# 把所有的同义词放到一个文档中，参考文档：https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-synonym-graph-tokenfilter.html
RUN mkdir /usr/share/elasticsearch/config/analysis && touch /usr/share/elasticsearch/config/analysis/synonyms.txt


# 使用命令构建失败
#USER root
#RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v${ELK_VERSION}/elasticsearch-analysis-ik-${ELK_VERSION}.zip


# 配置文件失败
#COPY ./config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml


EXPOSE 9200 9300
