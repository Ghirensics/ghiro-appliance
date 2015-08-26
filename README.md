Ghiro Appliance Builder
=======================

Ghiro appliance builder is a packer.io script to automagically create a Ghiro
appliance ready to be used, based on Ubuntu.

Using this script you should be able to create your onw Ghiro appliance updated
to Ghiro's developed branch. You can easily customize the appliance building
script to have your own customized appliance.

You can download latest stable appliance release on Ghiro website: http://getghiro.org

Getting started
---------------

Download and install Packer from http://packer.io
You must have VirtualBox installed and access to internet (to download Ubuntu's
packages).

Check out this repository and run:

    $ packer build template.json

You will see packer run an create the Ghiro appliance: spawn a Virtualbox
machine, run the initial setup, reboot, and install all software required.
It can take more or less 30 minutes depending on your system performance.

Setting a proxy
---------------

If you need to set a proxy to donwload installation packages from internet, set
the following line in http/preseed.cfg:

    d-i mirror/http/proxy string http://your_proxy_ip:your_proxy_port
    d-i mirror/https/proxy string https://your_proxy_ip:your_proxy_port

Hardware settings
-----------------

By default the appliance is created with the minimum hardware requirements:

 * 1 CPU
 * 1 Gb RAM

Giving more RAM and more CPUs is recommended if possible. More CPUs you can
assign faster image processing you get.

Configure networking
--------------------

By default the appliance is created with a bridged network interface on your
eth0 interface.
If you like different settings, just edit the virtual machine settings in your
virtualization software (i.e. VirtualBox, Vmware).