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