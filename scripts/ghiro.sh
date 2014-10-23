#!/bin/bash

# Setup mongo.
apt-get -y install mongodb

# Set Mysql password.
debconf-set-selections <<< 'mysql-server mysql-server/root_password password ghiromanager'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ghiromanager'

# Setup Mysql.
apt-get install -y mysql-server

# Setup python stuff.
apt-get install -y python-pip build-essential python-dev python-gi
apt-get install -y libgexiv2-2 gir1.2-gexiv2-0.10
# Pillow
apt-get install -y libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev python-tk

# Checkout ghiro from git.
cd /var/www
git clone https://github.com/Ghirensics/ghiro.git
cd ghiro

# Setup python requirements using pypi.
pip install -r requirements.txt

# Ghiro setup.
python manage.py syncdb --noinput

# Create super user.
echo "from django.contrib.auth.models import User; User.objects.create_superuser('ghiro', 'yourmail@example.com', 'ghiromanager')" | python manage.py shell