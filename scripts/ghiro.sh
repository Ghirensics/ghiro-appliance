#!/bin/bash

# Setup mongo.
apt-get -y install mongodb

# Set Mysql password.
debconf-set-selections <<< 'mysql-server mysql-server/root_password password ghiromanager'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ghiromanager'

# Setup Mysql.
apt-get install -y mysql-server

# Create ghiro db.
mysqladmin --defaults-extra-file=/etc/mysql/debian.cnf create ghiro

# Setup python stuff.
apt-get install -y python-pip build-essential python-dev python-gi
apt-get install -y libgexiv2-2 gir1.2-gexiv2-0.10
# Pillow
apt-get install -y libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev python-tk

# Install Apache.
apt-get install -y apache2 libapache2-mod-wsgi

# Deps for scipy.
apt-get install -y libblas-dev liblapack-dev libatlas-base-dev gfortran python-dev

# Install and configure wkhtmltopdf
apt-get install -y wkhtmltopdf xvfb
printf '#!/bin/bash\nxvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' > /usr/bin/wkhtmltopdf.sh
chmod a+x /usr/bin/wkhtmltopdf.sh
ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf

# Upgrade pip
pip install --upgrade pip

# Checkout ghiro from git.
cd /var/www
git clone https://github.com/Ghirensics/ghiro.git
cd ghiro

# Configure ghiro
cat <<EOF > ghiro/local_settings.py
LOCAL_SETTINGS = True
from settings import *

DATABASES = {
    'default': {
        # Engine type. Ends with 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'ENGINE': 'django.db.backends.mysql',
        # Database name or path to database file if using sqlite3.
        'NAME': 'ghiro',
        # Credntials. The following settings are not used with sqlite3.
        'USER': 'root',
        'PASSWORD': 'ghiromanager',
        # Empty for localhost through domain sockets or '127.0.0.1' for localhost through TCP.
        'HOST': '',
        # Set to empty string for default port.
        'PORT': '',
        # Set timeout (avoids SQLite "database is locked" errors).
        'timeout': 300,
    }
}

# MySQL tuning.
DATABASE_OPTIONS = {
 "init_command": "SET storage_engine=INNODB",
}

# Mongo database settings
MONGO_URI = "mongodb://localhost/"
MONGO_DB = "ghirodb"

# Max uploaded image size (in bytes).
# Default is 150MB.
MAX_FILE_UPLOAD = 157286400

# Allowed file types.
ALLOWED_EXT = ['image/bmp', 'image/x-canon-cr2', 'image/jpeg', 'image/png',
               'image/x-canon-crw', 'image/x-eps', 'image/x-nikon-nef',
               'application/postscript', 'image/gif', 'image/x-minolta-mrw',
               'image/x-olympus-orf', 'image/x-photoshop', 'image/x-fuji-raf',
               'image/x-panasonic-raw2', 'image/x-tga', 'image/tiff', 'image/pjpeg',
               'image/x-x3f', 'image/x-portable-pixmap']

# Override default secret key stored in secret_key.py
# Make this unique, and don't share it with anybody.
# SECRET_KEY = "YOUR_RANDOM_KEY"

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = "en-us"

ADMINS = (
    # ("Your Name", "your_email@example.com"),
)

MANAGERS = ADMINS

# Allow verbose debug error message in case of application fault.
# It's strongly suggested to set it to False if you are serving the
# web application from a web server front-end (i.e. Apache).
DEBUG = True

# A list of strings representing the host/domain names that this Django site
# can serve.
# Values in this list can be fully qualified names (e.g. 'www.example.com').
# When DEBUG is True or when running tests, host validation is disabled; any
# host will be accepted. Thus it's usually only necessary to set it in production.
ALLOWED_HOSTS = ["*"]

# Automatically checks once a day for updates.
# Set it to False to disable update check.
UPDATE_CHECK = True

# Auto upload is used to upload ana analyze files from a directory, monitoring
# it for changes.
# It is usually used to upload images via a shared folder or FTP.
# It should be an absolute path.
# Example: "/home/ghiro_share"
AUTO_UPLOAD_DIR = "/tmp/ghiroshare"
# Delete a file after upload and submission.
# The default behaviour is True.
# WARNING: It is not suggested to set it to False, because you will re-submit images
# each startup.
AUTO_UPLOAD_DEL_ORIGINAL = True
# Clean up AUTO_UPLOAD_DIR when startup.
# The default behaviour is True.
# WARNING: It is not suggested to set it to False, because you will re-submit images
# each startup.
AUTO_UPLOAD_STARTUP_CLEANUP = True

# Auditing.
# Logs all user actions.
AUDITING_ENABLED = True

# Log directory. Here is where Ghiro puts all logs.
LOG_DIR = "/tmp/log/"
# File name used for image processor log.
LOG_PROCESSING_NAME = "processing.log"
# Processor log maximum size.
LOG_PROCESSING_SIZE = 1024*1024*16 # 16 megabytes
# How many copies of processor log keep while rotating logs.
LOG_PROCESSING_NUM = 3 # keep 3 copies
# File name used for audit log.
LOG_AUDIT_NAME = "audit.log"
# Audit log maximum size.
LOG_AUDIT_SIZE = 1024*1024*16 # 16 megabytes
# How many copies of audit log keep while rotating logs.
LOG_AUDIT_NUM = 3 # keep 3 copies

# Enable JSON export to file for analysis results.
# This will create a JSON file for each analysis.
JSON_EXPORT = False
EOF

# Setup python requirements using pypi.
pip install -r requirements.txt

# Additional Mysql driver.
apt-get install libmysqlclient-dev
pip install MySQL-python

# Ghiro setup.
python manage.py syncdb --noinput

# Create super user.
echo "from users.models import Profile; Profile.objects.create_superuser('ghiro', 'yourmail@example.com', 'ghiromanager')" | python manage.py shell

#
# Apache service.
#

# Remove default virtualhost.
a2dissite 000-default

# Configure mod_wsgi and default virtual host.
cat <<EOF > /etc/apache2/sites-available/ghiro.conf
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

#
# Ghiro service.
#

# Adding processor init script.
cat <<EOF > /etc/init/ghiro.conf
description     "Ghiro"

start on started mysql
stop on shutdown
chdir /var/www/ghiro/
script
    exec /usr/bin/python manage.py process
end script
EOF

# Start ghiro service.
service ghiro start

#
# Appliance login banner.
#

# Create Ghiro issue.
cat <<EOF > /etc/network/if-up.d/ghirobanner
#!/bin/sh

IP=\`/sbin/ifconfig | grep "inet addr" | grep -v "127.0.0.1" | awk '{ print \$2 }' | awk -F: '{ print \$2 }'\`
cat <<FOO > /etc/issue
###############################
# Welcome to Ghiro Appliance! #
###############################

HOW TO START
------------

Appliance IP address is: \$IP
To start using Ghiro point your browser to http://\$IP

Default credentials:
  username: ghiro
  password: ghiromanager

*** Remember to change the password at your first access. ***
FOO
EOF

cat <<FOO > /etc/issue.net
Ghiro Appliance
FOO

chmod +x /etc/network/if-up.d/ghirobanner

#
# FTP Server.
#

# Setup FTP server.
apt-get install -y --no-install-recommends vsftpd

# Prepare.
mkdir -p /var/run/vsftpd/empty \
&& mkdir -p /etc/vsftpd \
&& mkdir -p /var/ftp \
&& mv /etc/vsftpd.conf /etc/vsftpd.orig

# Configure.
cat <<EOF > /etc/vsftpd.conf
listen=YES
anonymous_enable=YES
dirmessage_enable=YES
use_localtime=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
write_enable=NO
seccomp_sandbox=NO
xferlog_std_format=NO
log_ftp_protocol=YES
anon_root=/tmp/ghiroshare
pasv_max_port=13000
pasv_min_port=12000
max_per_ip=200
max_login_fails=200
max_clients=200
anon_max_rate=0
ftpd_banner="Welcome to Ghiro Appliance FTP"
EOF

# Reboot.
service vsftpd restart

#
# Samba server.
#

# Setup.
apt-get install -yq samba




