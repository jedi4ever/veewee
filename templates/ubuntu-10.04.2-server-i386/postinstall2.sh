#as root
apt-get -y install curl
apt-get -y install git

#as non root
bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> $HOME/.bash_profile
source "$HOME/.rvm/scripts/rvm"
rvm install ree