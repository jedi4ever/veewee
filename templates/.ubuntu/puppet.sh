if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Add puppet user and group
adduser --system --group --home /var/lib/puppet puppet

# Installing Puppet
gem install puppet --no-ri --no-rdoc
