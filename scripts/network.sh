
echo root:vagrant | chpasswd
echo "10.0.0.11 controller" >> /etc/hosts
echo "10.0.0.21 network" >> /etc/hosts
echo "10.0.0.31 compute1" >> /etc/hosts


sudo apt-get update
sudo apt-get install -y python-mysqldb

# Installing Utilities
sudo apt-get install -y python-software-properties
sudo apt-get install emacs
sudo apt-get update -y
sudo reboot
