#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "pulising_layer_ip" >&2
  exit 1
fi
cd
sudo apt-get -y install mariadb-server-10.1
sudo mysql -u root -e "use mysql; update user set plugin='' where User='root'; update user set password=PASSWORD('root') where User='root';flush privileges;"
cd
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.6.0.tar.gz
tar xzf elasticsearch-6.6.0.tar.gz
cd elasticsearch-6.6.0
./bin/elasticsearch -d
cd
wget http://dist.neo4j.org/neo4j-community-3.5.2-unix.tar.gz
tar xzf neo4j-community-3.5.2-unix.tar.gz
cd neo4j-community-3.5.2
sed -i 's/#dbms.security.auth_enabled=false/dbms.security.auth_enabled=false/g' conf/neo4j.conf
./bin/neo4j start
cd
sudo apt-get -y install git
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"'>> ~/.bashrc
source ~/.bashrc
sudo apt-get install -y libssl-dev libreadline-dev zlib1g-dev
sudo apt-get -y install build-essential
sudo apt-get -y install libxml2-dev libcurl4-openssl-dev default-libmysqlclient-dev
rbenv install 2.4.2
rbenv global 2.4.2
ruby -v
gem install bundler
gem install rails -v 5.1.4
rbenv rehash
cd
git clone am@$1:/git/eol_website_alt.git
cd eol_website_alt
bundle install
mysql -u root -proot -e " CREATE DATABASE ba_eol_development DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
rake db:migrate
rails s