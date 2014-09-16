# Update Repositories 

sudo yum update -y

# Installing the best text editor
sudo yum install -y emacs

# Networning 

#sudo service NetworkManager stop
#sudo service network start
#sudo chkconfig NetworkManager off
#sudo chkconfig network on

sudo service firewalld stop
sudo chkconfig firewalld off
sudo yum install -y iptables-services
sudo service iptables start
sudo chkconfig iptables on

echo root:vagrant | chpasswd
echo "10.0.0.11 controller" >> /etc/hosts
echo "10.0.0.21 network" >> /etc/hosts
echo "10.0.0.31 compute1" >> /etc/hosts

sudo service network restart


# Network Time Protocol (NTP)
#sudo yum install ntp -y

#sudo sed -i "21s/.*/server 0.north-america.pool.ntp.org iburst/" /etc/ntp.conf
#sudo sed -i "22s/.*/server 0.north-america.pool.ntp.org iburst/" /etc/ntp.conf
#sudo sed -i "23s/.*/server 0.north-america.pool.ntp.org iburst/" /etc/ntp.conf
#sudo sed -i "24s/.*/server 0.north-america.pool.ntp.org iburst/" /etc/ntp.conf

#sudo bash -c 'echo "restrict -4 default kod notrap nomodify" >> /etc/ntp.conf'
#sudo bash -c 'echo "restrict -6 default kod notrap nomodify" >> /etc/ntp.conf'

#sudo service ntpd start
#sudo  chkconfig ntpd on

# MySQL Server
sudo yum install mariadb-server mariadb -y
sudo sed -i '10i\bind-address = 10.0.0.11' /etc/my.cnf
sudo sed -i '11i\character-set-server = utf8' /etc/my.cnf
sudo sed -i "12i\init-connect = 'SET NAMES utf8'" /etc/my.cnf 
sudo sed -i '13i\collation-server = utf8_general_ci' /etc/my.cnf 
sudo sed -i '14i\innodb_file_per_table' /etc/my.cnf 
sudo sed -i '15i\default-storage-engine = innodb' /etc/my.cnf 
sudo service mariadb start
sudo chkconfig mariadb on

mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "UPDATE mysql.user SET Password=PASSWORD('a7060f997fbff5065008') WHERE User='root';"
mysql -e "FLUSH PRIVILEGES;"


# Installing common tools                                               
sudo yum install -y MySQL-python
sudo yum install -y yum-plugin-priorities

# Messaging Service
#sudo apt-get install -y rabbitmq-server
#sudo rabbitmqctl change_password guest a7060f997fbff5065008

# Identity Service
#sudo apt-get install -y keystone
#sudo sed -i '626s/^.*$/connection = mysql:\/\/keystone:a7060f997fbff5065008@controller\/keystone/' /etc/keystone/keystone.conf  
#sudo rm -f /var/lib/keystone/keystone.db
