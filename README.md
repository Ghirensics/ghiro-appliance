Ghiro Appliance Builder
=======================

Ghiro appliance builder is a packer.io script to automagically create a Ghiro
appliance ready to be used, based on Ubuntu.

You can download latest appliance release on Ghiro website: http://getghiro.org

Gettting started
----------------

Download and install Packer from http://packer.io
You must have VirtualBox installed and access to internet (to download Ubuntu's
packages).

Download this repository and run:

    $ packer build template.json

You will see packer run an create the Ghiro appliance.

Setting a proxy
---------------

If you need to set a proxy to donwload installation packages from internet, set
the following line in http/preseed.cfg:

    d-i mirror/http/proxy string http://your_proxy_ip:your_proxy_port
    d-i mirror/https/proxy string https://your_proxy_ip:your_proxy_port