#!/bin/bash
echo "please enter server IP"
read IP
echo "please enter path of solr schema and config with 2 files named managed-schema and solrconfig.xml"
read SCHEMA
# install neo4j
# Neo4j is the world’s leading Graph Database. It is a high performance
# graph store with all the features expected of a mature and robust database,
# like a friendly query language and ACID transactions.
# It is responsible for building the hierarchy of the species. We have two
# different relations between different species; first is the parent-child
# relationship. The other is synonym relationship.
cd
wget http://dist.neo4j.org/neo4j-community-3.5.2-unix.tar.gz
tar xzf neo4j-community-3.5.2-unix.tar.gz
cd neo4j-community-3.5.2 
file1=conf/neo4j.conf
sed -i 's/#dbms.security.auth_enabled=false/dbms.security.auth_enabled=false/g' $file1
sed -i 's/#dbms.connector.bolt.listen_address=:7687/dbms.connector.bolt.listen_address=0.0.0.0:7687/g' $file1
sed -i 's/#dbms.connector.http.listen_address=:7474/dbms.connector.http.listen_address='$IP':7474/g' $file1
sed -i 's/#dbms.connectors.default_advertised_address=localhost/dbms.connectors.default_advertised_address='$IP'/g' $file1
./bin/neo4j start

# install solrcloud with 2 nodes and embedded zookeeper
# This is implemented as a database for the taxon matching algorithm. This
# algorithm is responsible to match the input records to the corresponding
# species in the dynamic hierarchy.
# These steps are done using solr version 7.5.0
cd
wget http://apache.mirror1.spango.com/lucene/solr/7.5.0/solr-7.5.0.tgz
tar xzf solr-7.5.0.tgz solr-7.5.0/bin/install_solr_service.sh --strip-components=2
sudo bash ./install_solr_service.sh solr-7.5.0.tgz
sudo "/opt/solr/bin/solr" start -cloud -p 8983 -s "/opt/solr/example/cloud/node1/solr" -force
sudo "/opt/solr/bin/solr" start -cloud -p 7574 -s "/opt/solr/example/cloud/node2/solr" -z localhost:9983 -force
# create solr collection called indexer
sudo /opt/solr/bin/solr create -c indexer -s 2 -rf 2 -d _default -force
sudo curl http://localhost:7574/solr/indexer/config -d '{"set-user-property":{"update.autoCreateFields":"false"}}'
# upload schema and config file
cd /opt/solr/server/scripts/cloud-scripts
sudo sh zkcli.sh -cmd upconfig -zkhost localhost:9983 -collection indexer -confname indexer -solrhome ../solr -confdir $SCHEMA

cd
# restart two nodes of solr
sudo /opt/solr/bin/solr restart -c -p 8983 -s /opt/solr/example/cloud/node1/solr -force
sudo /opt/solr/bin/solr restart -c -p 7574 -z localhost:9983 -s /opt/solr/example/cloud/node2/solr -force

#install tomcat8
cd
sudo apt-get -y install tomcat8
sudo touch /etc/authbind/byport/80
sudo chmod 500 /etc/authbind/byport/80
sudo chown tomcat8 /etc/authbind/byport/80
file2=/etc/tomcat8/server.xml
file3=/etc/default/tomcat8
sudo sed -i 's/Connector port="8080" protocol=/Connector port="80" protocol=/g' $file2
sudo sed -i 's/#AUTHBIND=no/AUTHBIND=yes/g' $file3
sudo service tomcat8 restart


