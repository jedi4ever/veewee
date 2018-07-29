apt-get -y install libyaml-0-2 ruby2.0 ruby2.0-dev

# https://bugs.launchpad.net/ubuntu/+source/ruby2.0/+bug/1310292 
for i in erb gem irb rake rdoc ri ruby testrb
do
  dpkg-divert --add --rename --divert /usr/bin/${i}.divert /usr/bin/${i}
  update-alternatives --install /usr/bin/${i} ${i} /usr/bin/${i}2.0 1
#  ln -sf /usr/bin/${i}2.0 /usr/bin/${i}
done

echo '' > /etc/profile.d/vagrantruby.sh
