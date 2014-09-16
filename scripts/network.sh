# Update Repositories                                                                                 
sudo yum update-y

# Installing Utils                                                                                                 
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
#sudo yum install -y ntp
#sudo sed -i "21s/.*/server controller iburst/" /etc/ntp.conf
#sudo sed -i "22s/.*//" /etc/ntp.conf
#sudo sed -i "23s/.*//" /etc/ntp.conf
#sudo sed -i "24s/.*//" /etc/ntp.conf

#sudo service ntpd start
#sudo chkconfig ntpd on

# Installing common tools                                            
sudo yum install -y MySQL-python
sudo yum install -y yum-plugin-priorities


# Installing Utilities
#sudo apt-get install -y python-software-properties
#sudo apt-get install emacs
#sudo apt-get update -y
#sudo reboot
