apt-get -y autoremove
apt-get -y clean

echo "cleaning up gest additions"
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?

echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

echo "cleaning up udev rules"
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync