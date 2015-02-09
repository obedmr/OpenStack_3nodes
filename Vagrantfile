# -*- mode: ruby -*-
# vi: set ft=ruby :
 
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
  config.vm.box = "chef/centos-7.0"
 
  # Turn off shared folders
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
 
  # Controller node
  config.vm.define "controller" do |controller_config|
    controller_config.vm.hostname = "controller"
    controller_config.vm.provision "shell", path: "scripts/controller.sh"
    controller_config.vm.network "private_network", ip: "10.0.0.11"
    controller_config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", "1024"]
        v.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end
  # End controller node

 # Compute node                                                                                      
  config.vm.define "compute1" do |compute1_config|
    compute1_config.vm.hostname = "compute1"
    #compute1_config.vm.provision "shell", path: "scripts/compute.sh"

    compute1_config.vm.network "private_network", ip: "10.0.0.31"
    compute1_config.vm.network "private_network", ip: "10.0.1.31"
    
    compute1_config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", "1024"]
        v.customize ["modifyvm", :id, "--cpus", "4"]
    end
  end
  # End Compute node 

  # Network node                                                                  
  config.vm.define "network" do |network_config|
    network_config.vm.hostname = "network"
    #network_config.vm.provision "shell", path: "scripts/network.sh"

    network_config.vm.network "private_network", ip: "10.0.0.21"
    network_config.vm.network "private_network", ip: "10.0.1.21"
    network_config.vm.network "private_network", ip: "10.0.0.2"

    network_config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", "512"]
      v.customize ["modifyvm", :id, "--cpus", "1"]
      v.customize ["modifyvm", :id, "--nic3", "intnet"] 
    end
  end
  # End Network node

end
