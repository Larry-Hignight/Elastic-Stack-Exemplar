# Elastic-Stack-Exemplar

This document capture a wide-variety of notes that I've collected while using the products that copromise the Elastic stack.  Unless stated otherwise, the various Elastic products described below were installed and run using Docker on top of an AWS EC2 micro instance.

* [Docker @ Elastic](https://www.docker.elastic.co/#)
  * This page covers the entire suite of Elastic products
  * Elastic uses their own, dedicated, Docker registry

The following files were created to make using the ES products easier:
* bulk-load-json-convertor.R - Convert one or more CSV files into the "bulk load" JSON format expected by Elastic Search
  * See the Bulk API section below for more details
* time-util.R - Utility code for creating random date/times and sessions of various random lengths
    * Uniform distribution of dates; Gaussian distribution of times
    * Useful when creating mock data that includes realistic "sessions"

## Elastic Search
### Elastic Search - Installation
Due to limited memory, it can be difficult getting ES to start and run correctly on a free AWS EC2 micro instance.  However, I've been able to store over 15K documents and over 50K packetbeats when starting ES using the settings below:

* docker pull docker.elastic.co/elasticsearch/elasticsearch:6.1.1
* sudo docker run -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms128m -Xmx128m" docker.elastic.co/elasticsearch/elasticsearch:6.0.1

### [ElasticSearch - Basic Concepts](https://www.elastic.co/guide/en/elasticsearch/reference/current/_basic_concepts.html)

* Near Realtime (NRT)
  * Elasticsearch is a near real time search platform. There is a slight latency (< 1s) from the time you index a document until the time it becomes searchable.

* Cluster
  * A cluster is a collection of one or more nodes (servers)
  * Together they hold your entire data and provides federated indexing and search capabilities across all nodes
  * A cluster is identified by a unique name which by default is "elasticsearch"
  * A node can only be part of a cluster if the node is set up to join the cluster by its name
  * There is no limit on the number of nodes that can join a cluster
  * There is no limit on the number of indexes in a cluster

* Node
  * A node is a single server that is part of your cluster
  * Nodes store data, and participates in the cluster’s indexing and search capabilities
  * Like a cluster, a node is identified by a name, by default is a UUID, that is assigned to the node at startup

* Index
  * A collection of documents that have somewhat similar characteristics
    * For example, you can have an index for customer data, another index for a product catalog, and yet another index for order data
  * Indices are identified by an all lowercase name used when performing indexing, search, update, and delete operations against the documents in it
  * There is no limit on the number of indexes in a cluster

* Type
  * Deprecated in 6.0.0.
  * A type used to be a logical category/partition of your index to allow you to store different types of documents in the same index

* Document
  * A document is a basic unit of information that can be indexed
    * For example, you can have a document for a single customer, another document for a single product, and yet another for a single order
  * This document is expressed in JSON
  * A document physically resides in an index

* Shards & Replicas
  * An index can be subdivided into multiple pieces called shards
  * When you create an index, you can define the number of shards that you want
  * Each shard is in itself a fully-functional and independent "index" that can be hosted on any node in the cluster
  * Sharding is important for two primary reasons:
    * It allows you to horizontally split/scale your content volume
    * It allows you to distribute and parallelize operations across shards (potentially on multiple nodes) thus increasing performance/throughput
  * Replication is important for two primary reasons:
    * It provides high availability in case a shard/node fails
      * It is important to note that a replica shard is never allocated on the same node as the original/primary shard
    * It allows you to scale out your search volume/throughput since searches can be executed on all replicas in parallel
  * The number of shards and replicas can be defined per index at the time the index is created
  * The number of replicas can be chagned dynamically, but you cannot change the number of shards after-the-fact
  * By default, each index in Elasticsearch is allocated 5 primary shards and 1 replica
    * If you have at least two nodes in your cluster, your index will have 5 primary shards and another 5 replica shards
  * Each Elasticsearch shard is a Lucene index:
    * There is a maximum number of documents you can have in a single Lucene index (As of LUCENE-5843, the limit is ~2 billion documents)
    * You can monitor shard sizes using the _cat/shards API

### Elastic Search - Basic Commands
* [Check Cluster Health](https://www.elastic.co/guide/en/elasticsearch/reference/current/_cluster_health.html)
  * GET /_cat/health?v
    * curl 'localhost:9200/_cat/health?v'
* [List All Nodes](https://www.elastic.co/guide/en/elasticsearch/reference/current/_cluster_health.html)
  * GET /_cat/nodes?v
* [List All Indices](https://www.elastic.co/guide/en/elasticsearch/reference/current/_list_all_indices.html)
  * GET /_cat/indices?v
* [Create an Index](https://www.elastic.co/guide/en/elasticsearch/reference/current/_create_an_index.html):
  * PUT /index?pretty
    * curl -X PUT 'localhost:9200/customer?pretty'
  * GET /_cat/indices?v
* [Index and Query a Document](https://www.elastic.co/guide/en/elasticsearch/reference/current/_index_and_query_a_document.html):
  * PUT /index/doc/id?pretty
    * where index is the name of the index and id is a numeric identifier
    * curl -H 'Content-Type: application/json' -X PUT -d '{"name": "Larry"}' 'localhost:9200/customer/doc/1?pretty'
  * GET /index/doc/id?pretty
    * curl 'localhost:9200/customer/doc/1?pretty'
    * curl 'localhost:9200/customer/doc/1/_source?pretty'
      * To show only the "\\_source" info for the document
  * POST /index/doc?pretty
    * ElasticSearch will generate a random ID for the document index
    * curl -H 'Content-Type: application/json' -X POST -d '{"name": "Courtney"}' 'localhost:9200/customer/doc?pretty'
* [Delete an Index](https://www.elastic.co/guide/en/elasticsearch/reference/current/_delete_an_index.html)
  * DELETE /customer?pretty
    * curl -X DELETE 'localhost:9200/customer?pretty'
  * GET /_cat/indices?v
* [Update a Document](https://www.elastic.co/guide/en/elasticsearch/reference/current/_updating_documents.html)
  * POST /customer/doc/1/_update?pretty
    * curl -H 'Content-Type: application/json' -d '{"name": "Sir Lawrence", "Age": "Old"}' -X POST 'localhost:9200/customer/doc/1?pretty'
* [Delete a Document](https://www.elastic.co/guide/en/elasticsearch/reference/current/_deleting_documents.html)
  * DELETE /index/doc/id?pretty
* [Batch Processing](https://www.elastic.co/guide/en/elasticsearch/reference/current/_batch_processing.html)

### [Elastic Search - Search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/_the_search_api.html)

### Elastic Search - Cluster Health

### [Elastic Search - Bulk API](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html)

### Elastic Search - Useful Links
* [Elasticsearch Reference (ver 6.0)](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
* [Installing Elasticsearch using Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)
* [X-PAC for Elastic Stack](https://www.elastic.co/guide/en/x-pack/6.0/xpack-introduction.html)
* [Removal of mapping types](https://www.elastic.co/guide/en/elasticsearch/reference/6.x/removal-of-types.html)

## Beats
### PacketBeat
#### PacketBeat Install

