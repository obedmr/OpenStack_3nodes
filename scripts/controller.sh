
echo root:vagrant | chpasswd
echo "10.0.0.11 controller" >> /etc/hosts
echo "10.0.0.21 network" >> /etc/hosts
echo "10.0.0.31 compute1" >> /etc/hosts

sudo apt-get update 


# MySQL Server
echo mysql-server mysql-server/root_password password a7060f997fbff5065008 | debconf-set-selections
echo mysql-server mysql-server/root_password_again password a7060f997fbff5065008 | debconf-set-selections
sudo apt-get install -y python-mysqldb mysql-server 
sudo sed '47s/.*/bind-address = 10.0.0.11/' /etc/mysql/my.cnf > tmp_my.cnf
sudo sed -e '109acharacter-set-server = utf8' tmp_my.cnf > tmp_my2.cnf
sudo sed -e "109ainit-connect = 'SET NAMES utf8'" tmp_my2.cnf > tmp_my3.cnf
sudo sed -e '109acollation-server = utf8_general_ci' tmp_my3.cnf > tmp_my4.cnf
sudo sed -e '109ainnodb_file_per_table' tmp_my4.cnf > tmp_my5.cnf
sudo sed -e '109adefault-storage-engine = innodb' tmp_my5.cnf > tmp_my6.cnf
sudo mv tmp_my6.cnf /etc/mysql/my.cnf
sudo rm *.cnf
sudo service mysql restart

# Installinf Utilities
sudo apt-get install -y python-software-properties
sudo apt-get install -y emacs
sudo apt-get update -y
sudo reboot

# Messaging Server
sudo apt-get install -y rabbitmq-server
sudo rabbitmqctl change_password guest a7060f997fbff5065008

# Identity Service
sudo apt-get install -y keystone


