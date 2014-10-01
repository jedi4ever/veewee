# Install Ruby from sources

# add epel repo for Ruby compile time dependencies
cat > /etc/yum.repos.d/epel.repo << EOM
[epel]
name=epel
baseurl=http://download.fedoraproject.org/pub/epel/5/\$basearch
enabled=1
gpgcheck=0
includepkgs=libffi*
EOM

# Install required library packages
yum install -y gdbm-devel libffi-devel ncurses-devel

# Install LibYAML (prerequisite for Ruby)
YAML_VERSION=0.1.4
wget http://pyyaml.org/download/libyaml/yaml-$YAML_VERSION.tar.gz
tar xzvf yaml-$YAML_VERSION.tar.gz
cd yaml-$YAML_VERSION
./configure --prefix=/opt
make && make install
cd ..
rm -rf yaml-$YAML_VERSION
rm -f yaml-$YAML_VERSION.tar.gz

# Install Ruby
RUBY_VERSION=1.9.3-p484
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-$RUBY_VERSION.tar.gz
tar xvzf ruby-$RUBY_VERSION.tar.gz
cd ruby-$RUBY_VERSION
# Fix: BSD compatibility arguments not supported by the installed version of sed
sed -i "s/sed -E/sed -e/" configure
./configure --prefix=/opt/ruby --disable-install-doc --with-opt-dir=/opt
make && make install
cd ..
rm -rf ruby-$RUBY_VERSION
rm -f ruby-$RUBY_VERSION.tar.gz

# remove epel repo
rm -rf /etc/yum.repos.d/epel.repo
