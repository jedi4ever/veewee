#!/bin/sh

mkdir /store/firewall

# Copy the service.xml firewall rules to a central storage
# so they can survive reboot
cp /etc/vmware/firewall/service.xml /store/firewall

# Remove end tag so rule addition works as expected
sed -i "s/<\/ConfigRoot>//" /store/firewall/service.xml

# Add rule for vnc connections
echo "
  <service id='0033'>
    <id>vnc</id>
    <rule id='0000'>
      <direction>inbound</direction>
      <protocol>tcp</protocol>
      <porttype>dst</porttype>
      <port>
        <begin>5900</begin>
        <end>5964</end>
      </port>
    </rule>
    <enabled>true</enabled>
    <required>false</required>
  </service>
</ConfigRoot>" >> /store/firewall/service.xml

# Copy updated service.xml firewall rules to expected location
# Refresh the firewall rules
cp /store/firewall/service.xml /etc/vmware/firewall/service.xml
esxcli network firewall refresh

sed -i "s/exit 0//" /etc/rc.local.d/local.sh

# Add steps to /etc/rc.local/local.sh to repeat these steps on reboot
echo "
cp /store/firewall/service.xml /etc/vmware/firewall/service.xml
esxcli network firewall refresh
exit 0" >> /etc/rc.local.d/local.sh
