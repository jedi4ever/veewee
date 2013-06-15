# Chef needs these
/opt/csw/bin/pkgutil -y -i CSWgmake
/opt/csw/bin/pkgutil -y -i CSWgcc4g++ CSWgcc4core

# These are needed to get a compiler working
# Mainly because chef depends on compiling some native gems
PATH=/opt/csw/bin:/opt/csw/gnu/:/opt/csw/gcc4/bin:$PATH
export PATH

/opt/csw/bin/gem install chef  --no-ri --no-rdoc
