GEM=/opt/ruby/bin/gem

adduser --system --group --home /var/lib/puppet puppet
$GEM install puppet --no-ri --no-rdoc
