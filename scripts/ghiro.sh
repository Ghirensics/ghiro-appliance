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
echo "from users.models import Profile; Profile.objects.create_superuser('ghiro', 'yourmail@example.com', 'ghiromanager')" | python manage.py shell

# Install Apache.
apt-get install -y apache2 libapache2-mod-wsgi

# Remove default virtualhost.
a2dissite default

# Configure mod_wsgi and default virtual host.
cat <<EOF > /etc/apache2/sites-available/ghiro
    <VirtualHost *:80>
        ServerAdmin webmaster@localhost
        WSGIProcessGroup ghiro
        WSGIDaemonProcess ghiro processes=5 threads=10 user=nobody group=nogroup python-path=/var/www/ghiro/ home=/var/www/ghiro/ display-name=local
        WSGIScriptAlias / /var/www/ghiro/ghiro/wsgi.py
        Alias /static/ /var/www/ghiro/static/
        <Location "/static/">
            Options -Indexes
        </Location>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>
EOF

# Enable ghiro virtualhost.
a2ensite ghiro

# Restart Apache.
service apache2 restart

# Adding processor init script.
cat <<EOF > /etc/init/ghiro.conf
description     "Ghiro"

start on started mysql
stop on shutdown
script
    chdir /var/www/ghiro/
    exec /usr/bin/python manage.py process
end script
EOF

# Start ghiro service.
service ghiro start
