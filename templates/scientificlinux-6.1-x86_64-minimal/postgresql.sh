cd /tmp
wget -q http://ftp.postgresql.org/pub/source/v9.1.3/postgresql-9.1.3.tar.gz
tar xzf postgresql-9.1.3.tar.gz
cd postgresql-9.1.3
./configure --quiet
gmake --quiet
gmake install
adduser postgres
mkdir /usr/local/pgsql/data
chown postgres /usr/local/pgsql/data
su - postgres
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
exit
cp contrib/start-scripts/linux /etc/rc.d/init.d/postgresql
cd ..
rm -fR postgresql-9.1.3*
chmod 775 /etc/rc.d/init.d/postgresql
chkconfig --add postgresql
chkconfig postgresql on
service postgresql start
echo 'PATH=$PATH:/usr/local/pgsql/bin/'> /etc/profile.d/postgresql.sh
