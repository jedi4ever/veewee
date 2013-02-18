if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Install Ruby from packages
apt-get -y install ruby rubygems ruby-dev
