
echo root:vagrant | chpasswd
echo "10.0.0.11 controller" >> /etc/hosts
echo "10.0.0.21 network" >> /etc/hosts
echo "10.0.0.31 compute1" >> /etc/hosts

sudo apt-get update 
sudo apt-get install python-mysqldb mysql-server -y
sed '4i\ bind-address = 10.0.0.11' /etc/mysql/my.cnf
