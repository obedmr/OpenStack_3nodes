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
sudo yum install mysql-server mysql -y
sudo sed -i '10i\bind-address = 10.0.0.11' /etc/my.cnf
sudo sed -i '11i\character-set-server = utf8' /etc/my.cnf
sudo sed -i "12i\init-connect = 'SET NAMES utf8'" /etc/my.cnf 
sudo sed -i '13i\collation-server = utf8_general_ci' /etc/my.cnf 
sudo sed -i '14i\innodb_file_per_table' /etc/my.cnf 
sudo sed -i '15i\default-storage-engine = innodb' /etc/my.cnf 
sudo service mysqld start
sudo chkconfig mysqld on

sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -e "UPDATE mysql.user SET Password=PASSWORD('a7060f997fbff5065008') WHERE User='root';"
sudo mysql -e "FLUSH PRIVILEGES;"


# Installing common tools                                               
sudo yum install -y MySQL-python
sudo yum install -y yum-plugin-priorities

# OpenStack packages
sudo yum install -y http://repos.fedorapeople.org/repos/openstack/openstack-icehouse/rdo-release-icehouse-4.noarch.rpm
sudo yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo yum install -y openstack-utils
sudo yum install -y openstack-selinux
sudo yum upgrade -y 
#sudo reboot

# Messaging Service
sudo yum install -y rabbitmq-server
sudo service rabbitmq-server start
sudo chkconfig rabbitmq-server on
sudo rabbitmqctl change_password guest a7060f997fbff5065008

# Identity Service
sudo yum install -y openstack-keystone python-keystoneclient
sudo openstack-config --set /etc/keystone/keystone.conf \
   database connection mysql://keystone:a7060f997fbff5065008@controller/keystone
mysql -u root -pa7060f997fbff5065008 -e " 
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost'  IDENTIFIED BY 'a7060f997fbff5065008';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%'   IDENTIFIED BY 'a7060f997fbff5065008';
"
sudo  /bin/sh -c "keystone-manage db_sync"

ADMIN_TOKEN=$(openssl rand -hex 10)
echo $ADMIN_TOKEN
sudo openstack-config --set /etc/keystone/keystone.conf DEFAULT \
   admin_token $ADMIN_TOKEN

sudo keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
sudo chown -R keystone:keystone /etc/keystone/ssl
sudo chmod -R o-rwx /etc/keystone/ssl
sudo chown keystone:keystone -R /var/log/keystone/

sudo service openstack-keystone start
sudo chkconfig openstack-keystone on

sudo /bin/sh -c "(crontab -l -u keystone 2>&1 | grep -q token_flush)"
sudo /bin/sh -c "echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/keystone"

export OS_SERVICE_TOKEN=$ADMIN_TOKEN
export OS_SERVICE_ENDPOINT=http://controller:35357/v2.0
keystone user-create --name=admin --pass=a7060f997fbff5065008 --email=admin@homecloud.com
keystone role-create --name=admin
keystone tenant-create --name=admin --description="Admin Tenant"
keystone user-role-add --user=admin --tenant=admin --role=admin
keystone user-role-add --user=admin --role=_member_ --tenant=admin
keystone user-create --name=demo --pass=demo --email=demo@homecloud.com
keystone tenant-create --name=demo --description="Demo Tenant"
keystone user-role-add --user=demo --role=_member_ --tenant=demo
keystone tenant-create --name=service --description="Service Tenant"

keystone service-create --name=keystone --type=identity \
  --description="OpenStack Identity"

 keystone endpoint-create \
  --service-id=$(keystone service-list | awk '/ identity / {print $2}') \
  --publicurl=http://controller:5000/v2.0 \
  --internalurl=http://controller:5000/v2.0 \
  --adminurl=http://controller:35357/v2.0


sudo /bin/sh -c "echo 'export OS_USERNAME=admin' >> /etc/keystone/admin-openrc.sh"
sudo /bin/sh -c "echo 'export OS_PASSWORD=a7060f997fbff5065008' >> /etc/keystone/admin-openrc.sh"
sudo /bin/sh -c "echo 'export OS_TENANT_NAME=admin' >> /etc/keystone/admin-openrc.sh"
sudo /bin/sh -c "echo 'export OS_AUTH_URL=http://controller:35357/v2.0' >> /etc/keystone/admin-openrc.sh"

# OpenStack Clients
sudo yum install -y python-ceilometerclient
sudo yum install -y python-cinderclient
sudo yum install -y python-glanceclient
sudo yum install -y python-heatclient
sudo yum install -y python-keystoneclient
sudo yum install -y python-neutronclient
sudo yum install -y python-novaclient
sudo yum install -y python-swiftclient
sudo yum install -y python-troveclient
