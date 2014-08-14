# -*- mode: ruby -*-
# vi: set ft=ruby :
 
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 
  config.vm.box = "precise64"
 
  # Turn off shared folders
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
 
  # Controller
  config.vm.define "controller" do |controller_config|
    controller_config.vm.hostname = "controller"
    controller_config.vm.provision "shell", path: "scripts/controller.sh"
    # eth1 configured in the 192.168.236.0/24 network
    controller_config.vm.network "private_network", ip: "192.168.236.10"
    controller_config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", "1024"]
        v.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end
  # End controller

end
