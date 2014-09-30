if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Default to not installing systemd
if [ "$USE_SYSTEMD" = yes ]; then
  apt-get install -y systemd

  cat > /etc/default/grub << EOF
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=Debian
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="init=/lib/systemd/systemd debian-installer=en_US"
EOF

  update-grub
fi
