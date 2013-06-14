# Install pre-requisites
yum -y install \
  rubygem-bunny \
  rubygem-erubis \
  rubygem-highline \
  rubygem-json \
  rubygem-mime-types \
  rubygem-net-ssh \
  rubygem-polyglot \
  rubygem-rest-client \
  rubygem-systemu \
  rubygem-treetop \
  rubygem-uuidtools

# chef 11.4.4 requires rubygems/format which is ruby 1.9 specific and fedora 19 comes with ruby 2.0
touch /usr/share/rubygems/rubygems/format.rb

# Install Chef
gem install --no-ri --no-rdoc chef

