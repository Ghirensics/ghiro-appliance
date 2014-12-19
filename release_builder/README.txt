GHIRO APPLIANCE release X_RELEASE
   http://getghiro.org

Import the .OVA file in your virtualization software (i.e. VirtualBox or Vmware).
For example in VirtualBox go in File > Import Appliance and select the .OVA file.

The appliance is configured by default with bridged networking on interface eth0,
if you get an error regarding your different setup or you like antoher network
setup just change it.

Start the appliance.

The appliance credentials are:
Username: ghiro
Password: ghiromanager

For extra security, remember to change the password at your first access.

The first time you have to properly configure the network interface.
Select the virtual networking you like (for example
bridged or NAT); by default the appliance is configured in bridged mode.
By default, Ghiro appliance will get an IP address using DHCP and show it in
the boot screen.

If you need to manually configure your IP address: login in, and configure the
networking card with your desired IP, for example to
give the IP 192.168.0.10 use the following command:

sudo ifconfig eth0 192.168.0.10 up

When Ghiro apppliance has an IP address, via DHCP or via manual configuration,
the web interface is reachable on default HTTP port 80/tcp, just put the
appliance address in your browser. For example:

http://192.168.0.10 (or other DHCP or manually configured adress)

The web interface credentials are:
Username: ghiro
Password: ghiromanager

For extra security, remember to change the password at your first access.

Now you can start analyzing images! Go in the "Cases" panel, create your first
case, and add your images with the add button.
For usage help please refer to the documentation at:
http://www.getghiro.org/docs/latest/usage/index.html

If you need to access remotely to the appliance you can use SSH.
The appliance is shipped with a default disk of 50GB, if is not enough you can
create another virtual disk and add that to the root volume using LVM.
