# Chef needs these
/opt/csw/bin/pkgutil -y -i CSWgmake
/opt/csw/bin/pkgutil -y -i CSWgcc4g++ CSWgcc4core
/opt/csw/bin/pkgutil -y -i CSWcurl

# Install Chef
curl -L https://www.opscode.com/chef/install.sh | bash
