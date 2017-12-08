# Elastic-Stack-Exemplar

Note - Elastic uses their own, dedicated, Docker registry.

## AWS Settings

Because of the limited memory, it is difficult getting ES to start on an AWS Micro Instance.  Try the following:

* sudo docker run -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms256m -Xmx256m" docker.elastic.co/elasticsearch/elasticsearch:6.0.1

## Useful Links
* [Elasticsearch Reference (ver 6.0)](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
* [Docker @ Elastic - Covers all of their products](https://www.docker.elastic.co/#)
* [Installing Elasticsearch using Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)
* [X-PAC for Elastic Stack](https://www.elastic.co/guide/en/x-pack/6.0/xpack-introduction.html)

