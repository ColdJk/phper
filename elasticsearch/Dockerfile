ARG ELK_VERSION=7.5.1
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELK_VERSION}



## =======================
# 通用镜像有apt，就可以用下面这个方法安装
# ENV VERSION ${ELK_VERSION}
# RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
#    apt-get update \
#    && apt-get install unzip \
#    && mkdir -p /usr/share/elasticsearch/plugins/analysis-ik \
#    && cd /usr/share/elasticsearch/plugins/analysis-ik \
#    && wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v$VERSION/elasticsearch-analysis-ik-$VERSION.zip && unzip elasticsearch-analysis-ik-$VERSION.zip
#    && unzip elasticsearch-analysis-ik-${ELK_VERSION}.zip \
#    && rm -rf elasticsearch-analysis-ik-${ELK_VERSION}.zip
## =======================


#
# ADD ./tmp/elasticsearch-analysis-ik-7.4.1.zip /usr/share/elasticsearch/plugins/analysis-ik

# ENV VERSION ${ELK_VERSION}
# RUN ./bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v$VERSION/elasticsearch-analysis-ik-$VERSION.zip

# 把所有的同义词放到一个文档中，参考文档：https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-synonym-graph-tokenfilter.html
RUN mkdir /usr/share/elasticsearch/config/analysis && touch /usr/share/elasticsearch/config/analysis/synonyms.txt


EXPOSE 9200 9300
