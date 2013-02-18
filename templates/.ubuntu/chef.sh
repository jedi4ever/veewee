if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Installing chef
gem install chef --no-ri --no-rdoc
