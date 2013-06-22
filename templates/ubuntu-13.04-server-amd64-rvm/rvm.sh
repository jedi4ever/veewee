curl -L get.rvm.io | bash -s stable
usermod --append --groups rvm vagrant
/usr/local/rvm/bin/rvm install 2.0.0-p195 
/usr/local/rvm/bin/rvm alias create default 2.0.0-p195