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

# Install Chef
gem install --no-ri --no-rdoc chef

