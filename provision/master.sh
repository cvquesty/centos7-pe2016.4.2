#!/bin/bash

# Perform a few steps first
export PATH=$PATH:/opt/puppetlabs/puppet/bin/

# Install Zack's r10k module
/opt/puppetlabs/puppet/bin/puppet module install 'zack-r10k'

# Install Hunner's Hiera module
/opt/puppetlabs/puppet/bin/puppet module install 'hunner-hiera'

# Stop and disable Firewalld
/bin/systemctl stop  firewalld.service
/bin/systemctl disable firewalld.service

# configure Hiera
cat > /var/tmp/configure_hiera.pp << 'EOF'
class { 'hiera':
  hiera_yaml => '/etc/puppetlabs/puppet/hiera.yaml',
  hierarchy  => [
    'nodes/%{clientcert}',
    '%{environment}',
    'common',
  ],
  logger     => 'console',
  datadir    => '/etc/puppetlabs/code/environments/%{environment}/hieradata'
}
EOF

# Then Configure Hiera
/opt/puppetlabs/puppet/bin/puppet apply /var/tmp/configure_hiera.pp

# Set up the Puppet Access Configuration
mkdir ~/.puppetlabs
echo '{"service-url":"https://master.puppetlabs.vm:4433/rbac-api"}' > ~/.puppetlabs/puppet-access.conf

# Create SSH Key Location
mkdir -p /etc/puppetlabs/puppetserver/ssh

# Generate SSH Keys
/usr/bin/ssh-keygen -t rsa -b 4096 -C "Puppet Vagrant" -f /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa -P ""

# Set Permissions on keys
chown -R pe-puppet:pe-puppet /etc/puppetlabs/puppetserver/ssh

# Add Important Packages
/usr/bin/yum -y install git

# Adding Deploy User to Deploy Code Group
curl -k -X POST -H 'Content-Type: application/json' https://master.puppetlabs.vm:4433/rbac-api/v1/users -d '{"login":"cmadmin","email":"cmadmin@master.puppetlabs.vm","display_name":"CM Admin","role_ids": [4],"password":"puppetlabs"}' --cert /etc/puppetlabs/puppet/ssl/certs/master.puppetlabs.vm.pem --key /etc/puppetlabs/puppet/ssl/private_keys/master.puppetlabs.vm.pem --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem

# Generate Deployment Token
echo "puppetlabs" | /opt/puppetlabs/bin/puppet-access login --username cmadmin --service-url https://master.puppetlabs.vm:4433/rbac-api --lifetime 180d

# Deploy all Code
/opt/puppetlabs/bin/puppet-code deploy --all

# Run the Puppet Agent
/opt/puppetlabs/puppet/bin/puppet agent -t || true
