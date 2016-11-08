# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  pe_version                    = '2016.4.2'
  config.pe_build.version       = pe_version

######################
## Puppet Master VM ##
######################
  # Define the Master VM Characteristics
  config.vm.define 'master' do |master|
    master.vm.box = 'puppetlabs/centos-7.2-64-nocm'
    master.vm.network :private_network, :ip => '10.10.100.100'
    master.vm.network "forwarded_port", guest: 443, host: 8443
    master.vm.hostname = 'master.puppetlabs.vm'

  # Configure Master VM Settings
  master.vm.provider :virtualbox do |settings|
    settings.memory = 4608
    settings.name = "c7master_2016.4.2"
    settings.cpus = 2
  end

  # Add all other hosts for environment
  master.vm.provision :hosts do |entries|
    entries.add_host '10.10.100.100', ['master.puppetlabs.vm', 'master']
    entries.add_host '10.10.100.110', ['development.puppetlabs.vm', 'development']
    entries.add_host '10.10.100.111', ['production.puppetlabs.vm', 'production']
  end

  # Set the PE Role for this node
  master.vm.provision :pe_bootstrap do |provisioner|
    provisioner.role = :master
    provisioner.answer_file = 'provision/pe.conf'
  end
    master.vm.provision :shell, path: "provision/master.sh"
  end

###################
## Develpment VM ##
###################
  # Define the Development VM Characteristics
  config.vm.define 'development' do |development|
    development.vm.box = 'puppetlabs/centos-7.2-64-nocm'
    development.vm.network :private_network, :ip => '10.10.100.110'
    development.vm.hostname = 'development.puppetlabs.vm'

  # Configure Development VM Settings
  development.vm.provider :virtualbox do |settings|
    settings.memory = 512
    settings.name = "c7development_2016.4.2"
    settings.cpus = 1
  end

  # Add all other hosts for environment
  development.vm.provision :hosts do |entries|
    entries.add_host '10.10.100.100', ['master.puppetlabs.vm', 'master']
    entries.add_host '10.10.100.110', ['development.puppetlabs.vm', 'development']
    entries.add_host '10.10.100.111', ['production.puppetlabs.vm', 'production']
  end

  # Set the PE Role of This Node
  development.vm.provision :pe_agent do |provisioner|
    provisioner.master = 'master.puppetlabs.vm'
  end
    development.vm.provision :shell, path: "provision/development.sh"
  end

###################
## Production VM ##
###################
  # Define the Production VM Characteristics
  config.vm.define 'production' do |production|
    production.vm.box = 'puppetlabs/centos-7.2-64-nocm'
    production.vm.network :private_network, :ip => '10.10.100.111'
    production.vm.hostname = 'production.puppetlabs.vm'

  # Configure Production VM Settings
  production.vm.provider :virtualbox do |settings|
    settings.memory = 512
    settings.name = "c7production_2016.4.2"
    settings.cpus = 1
  end

  # Add all other hosts for environment
  production.vm.provision :hosts do |entries|
    entries.add_host '10.10.100.100', ['master.puppetlabs.vm', 'master']
    entries.add_host '10.10.100.110', ['development.puppetlabs.vm', 'development']
    entries.add_host '10.10.100.111', ['production.puppetlabs.vm', 'production']
  end

  # Set the PE Role of This Node
  production.vm.provision :pe_agent do |provisioner|
    provisioner.master = 'master.puppetlabs.vm'
  end
    production.vm.provision :shell, path: "provision/production.sh"
  end
end
