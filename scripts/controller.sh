# Update Repositories 
yum update -y

# Installing the best text editor
yum install -y emacs-nox

# Networning 
service NetworkManager stop
service network start
chkconfig NetworkManager off
chkconfig network on

service firewalld stop
chkconfig firewalld off
yum install -y iptables-services
service iptables start
chkconfig iptables on

echo "10.0.0.11 controller" >> /etc/hosts
echo "10.0.0.21 network" >> /etc/hosts
echo "10.0.0.31 compute1" >> /etc/hosts

service network restart

echo root:vagrant | chpasswd

# Network Time Protocol (NTP)
yum install ntp -y

sed -i "21s/.*/server 0.north-america.pool.ntp.org iburst/" /etc/ntp.conf
sed -i "22s/.*/server 0.north-america.pool.ntp.org iburst/" /etc/ntp.conf
sed -i "23s/.*/server 0.north-america.pool.ntp.org iburst/" /etc/ntp.conf
sed -i "24s/.*/server 0.north-america.pool.ntp.org iburst/" /etc/ntp.conf

bash -c 'echo "restrict -4 default kod notrap nomodify" >> /etc/ntp.conf'
bash -c 'echo "restrict -6 default kod notrap nomodify" >> /etc/ntp.conf'

#service ntpd start
# chkconfig ntpd on

# Prerequesites
yum install -y yum-plugin-priorities
yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum install -y http://rdo.fedorapeople.org/openstack-juno/rdo-release-juno.rpm
yum -y upgrade
yum install -y openstack-selinux openstack-utils

# MySQL Server
yum install -y mariadb mariadb-server MySQL-python

sed -i '10i\bind-address = 10.0.0.11' /etc/my.cnf
sed -i '11i\character-set-server = utf8' /etc/my.cnf
sed -i "12i\init-connect = 'SET NAMES utf8'" /etc/my.cnf 
sed -i '13i\collation-server = utf8_general_ci' /etc/my.cnf 
sed -i '14i\innodb_file_per_table' /etc/my.cnf 
sed -i '15i\default-storage-engine = innodb' /etc/my.cnf 

systemctl enable mariadb.service
systemctl start mariadb.service

mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "UPDATE mysql.user SET Password=PASSWORD('a7060f997fbff5065008') WHERE User='root';"
mysql -e "FLUSH PRIVILEGES;"

# Messaging Service
yum install -y rabbitmq-server
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service
rabbitmqctl change_password guest a7060f997fbff5065008

# Identity Service
mysql -u root -pa7060f997fbff5065008 -e "
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost'  IDENTIFIED BY 'a7060f997fbff5065008';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%'   IDENTIFIED BY 'a7060f997fbff5065008';
FLUSH PRIVILEGES;
"
yum install -y openstack-keystone python-keystoneclient

ADMIN_TOKEN=$(openssl rand -hex 10)
echo $ADMIN_TOKEN
openstack-config --set /etc/keystone/keystone.conf DEFAULT \
		 admin_token $ADMIN_TOKEN

openstack-config --set /etc/keystone/keystone.conf \
		 database connection mysql://keystone:a7060f997fbff5065008@controller/keystone

openstack-config --set /etc/keystone/keystone.conf \
		 token provider keystone.token.providers.uuid.Provider

openstack-config --set /etc/keystone/keystone.conf \
		 token driver keystone.token.persistence.backends.sql.Token

openstack-config --set /etc/keystone/keystone.conf DEFAULT \
		 verbose True


keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
chown -R keystone:keystone /var/log/keystone
chown -R keystone:keystone /etc/keystone/ssl
chmod -R o-rwx /etc/keystone/ssl

su -s /bin/sh -c "keystone-manage db_sync" keystone

systemctl enable openstack-keystone.service
systemctl start openstack-keystone.service

/bin/sh -c "(crontab -l -u keystone 2>&1 | grep -q token_flush)"
/bin/sh -c "echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/keystone"

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


/bin/sh -c "echo 'export OS_USERNAME=admin' >> /etc/keystone/admin-openrc.sh"
/bin/sh -c "echo 'export OS_PASSWORD=a7060f997fbff5065008' >> /etc/keystone/admin-openrc.sh"
/bin/sh -c "echo 'export OS_TENANT_NAME=admin' >> /etc/keystone/admin-openrc.sh"
/bin/sh -c "echo 'export OS_AUTH_URL=http://controller:35357/v2.0' >> /etc/keystone/admin-openrc.sh"

# OpenStack Clients
yum install -y python-ceilometerclient
yum install -y python-cinderclient
yum install -y python-glanceclient
yum install -y python-heatclient
yum install -y python-keystoneclient
yum install -y python-neutronclient
yum install -y python-novaclient
yum install -y python-swiftclient
yum install -y python-troveclient

# Glance - Image Service
mysql -u root -pa7060f997fbff5065008 -e "
CREATE DATABASE glance DEFAULT CHARACTER SET utf8;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'a7060f997fbff5065008';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'a7060f997fbff5065008';
"

keystone user-create --name=glance --pass=a7060f997fbff5065008 \
	 --email=glance@homecloud.com

keystone user-role-add --user=glance --tenant=service --role=admin

keystone service-create --name glance --type image \
	 --description "OpenStack Image Service"

keystone endpoint-create \
	 --service-id $(keystone service-list | awk '/ image / {print $2}') \
	 --publicurl http://controller:9292 \
	 --internalurl http://controller:9292 \
	 --adminurl http://controller:9292 \
	   --region regionOne

yum install -y openstack-glance python-glanceclient

openstack-config --set /etc/glance/glance-api.conf database \
		 connection mysql://glance:a7060f997fbff5065008@controller/glance

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
		 auth_uri http://controller:5000/v2.0
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
		 identity_uri http://controller:35357
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
		 admin_tenant_name = service
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
		 admin_user = glance
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
		 admin_password  a7060f997fbff5065008

openstack-config --set /etc/glance/glance-api.conf paste_deploy \
		 flavor keystone

openstack-config --set /etc/glance/glance-api.conf glance_store \
		 default_store file
openstack-config --set /etc/glance/glance-api.conf glance_store \
		 filesystem_store_datadir /var/lib/glance/images/

openstack-config --set /etc/glance/glance-api.conf DEFAULT \
		 verbose True

openstack-config --set /etc/glance/glance-registry.conf database \
		 connection mysql://glance:a7060f997fbff5065008@controller/glance

openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
		 auth_uri http://controller:5000/v2.0
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
		 identity_uri http://controller:35357
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken \
		 admin_tenant_name = service
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
		 admin_user = glance
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken \
		 admin_password  a7060f997fbff5065008

openstack-config --set /etc/glance/glance-registry.conf paste_deploy \
		                  flavor keystone

openstack-config --set /etc/glance/glance-registry.conf DEFAULT \
		                  verbose True

su -s /bin/sh -c "glance-manage db_sync" glance

# Starting Glance Services
systemctl enable openstack-glance-api.service openstack-glance-registry.service
systemctl start openstack-glance-api.service openstack-glance-registry.service

#source /etc/keystone/admin-
mkdir /tmp/images
cd /tmp/images
wget http://cdn.download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img
#glance image-create --name "cirros-0.3.3-x86_64" --file cirros-0.3.3-x86_64-disk.img   --disk-format qcow2 --container-format bare --is-public True --progress
#glance image-create --name "cirros-0.3.3-x86_64" --file cirros-0.3.3-x86_64-disk.img   --disk-format qcow2 --container-format bare --progress





