if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Add puppet user and group
adduser --system --group --home /var/lib/puppet puppet

# Installing Puppet
if [ -z "$PUPPET_VERSION" ]; then
  # Default to latest
  gem install puppet --no-ri --no-rdoc
else
  gem install puppet --no-ri --no-rdoc --version $PUPPET_VERSION
fi
