echo ""

curl 'localhost:9200/_cat/health?v'
echo "" && echo ""

curl 'localhost:9200/_cat/nodes?v'
echo "" && echo ""

curl 'localhost:9200/_cat/indices?v'
echo "" && echo ""

vmstat -Sm
echo "" && echo ""

curl -XGET "http://localhost:9200/_cat/allocation?v&pretty"
echo "" && echo ""

df -h /
echo "" && echo ""


# Start the cluster... 
# sudo docker run -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms256m -Xmx256m" docker.elastic.co/elasticsearch/elasticsearch:6.0.1

# Bulk load data...
# curl -s --data-binary "@bulk_load.json" -H 'Content-Type: application/x-ndjson' -XPOST 'localhost:9200/_bulk'
