#!/bin/bash
if [ "$#" -ne 2 ]; then
  echo "hbase_data_directory mongodb_installtion_directory" >&2
  exit 1
fi
cd
sudo apt-get -y install tomcat8
sudo touch /etc/authbind/byport/80
sudo chmod 500 /etc/authbind/byport/80
sudo chown tomcat8 /etc/authbind/byport/80
file2=/etc/tomcat8/server.xml
sed -i 's/Connector port="8080" protocol=/Connector port="80" protocol=/g' $file2
sudo service tomcat8 restart
cd
wget https://archive.apache.org/dist/hbase/1.2.6/hbase-1.2.6-bin.tar.gz
tar xzf hbase-1.2.6-bin.tar.gz
cd hbase-1.2.6/
content="<property>\n<name>hbase.rootdir</name>\n<value>file://${1}/hbase</value>\n</property>\n<property>\n<name>hbase.zookeeper.property.dataDir</name>\n<value>${1}/zookeeper</value>\n</property>"
C=$(echo $content | sed 's/\//\\\//g')
sed -i "/<\/configuration>/ s/.*/${C}\n&/" conf/hbase-site.xml
./bin/start-hbase.sh
cd
sudo apt-get -y install mariadb-server-10.1
sudo mysql -u root -e "use mysql; update user set plugin='' where User='root'; update user set password=PASSWORD('root') where User='root';flush privileges;"
cd
mkdir mongodb
cd mongodb/
curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.4.7.tgz
tar xvf mongodb-linux-x86_64-3.4.7.tgz
mv mongodb-linux-x86_64-3.4.7 mongodb
cd mongodb
echo $PATH
export PATH=$PATH:$2/mongodb/mongodb/bin
mkdir data
cd bin/
./mongod --dbpath $2/mongodb/mongodb/data &
cd
wget https://www-eu.apache.org/dist/cassandra/3.11.3/apache-cassandra-3.11.3-bin.tar.gz
tar -xzvf apache-cassandra-3.11.3-bin.tar.gz
cd apache-cassandra-3.11.3
bin/cassandra
cd 
