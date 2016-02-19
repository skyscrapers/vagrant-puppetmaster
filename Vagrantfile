# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :machine
    config.cache.enable :apt
  end
  
  config.vm.define "puppetmaster" do |trusty|
    trusty.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
    trusty.vm.box_version = "= 1.0.1"
    trusty.vm.network :private_network, ip: "192.168.33.51"
    trusty.vm.hostname = "puppetmaster.vagrant.local"
    trusty.vm.synced_folder 'hiera/', '/etc/puppet/hieradata'
    trusty.vm.provider :virtualbox do |vb|
      vb.memory = 1024
      vb.name = "puppetmaster"
    end
  end

$script = <<SCRIPT
export DEBIAN_FRONTEND=noninteractive
apt-get update --fix-missing
apt-get install -y rubygems
gem install deep_merge
SCRIPT

  config.vm.provision :shell, inline: $script

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/environments/production"
    puppet.manifest_file  = "default.pp"
    puppet.hiera_config_path = "puppet/hiera.yaml"
    puppet.module_path = ["puppet/modules"]
  end
end
