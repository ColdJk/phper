ARG ELK_VERSION
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELK_VERSION}

# ADD ./tmp/elasticsearch-analysis-ik-7.4.1.zip /usr/share/elasticsearch/plugins/analysis-ik

# ENV VERSION ${ELK_VERSION}
# RUN ./bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v$VERSION/elasticsearch-analysis-ik-$VERSION.zip

# 把所有的同义词放到一个文档中，参考文档：https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-synonym-graph-tokenfilter.html
RUN mkdir /usr/share/elasticsearch/config/analysis && touch /usr/share/elasticsearch/config/analysis/synonyms.txt

# 配置文件
#COPY ./config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

EXPOSE 9200 9300
