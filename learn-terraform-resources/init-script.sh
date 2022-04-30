#!/bin/bash
yum update -y
yum -y remove httpd
yum -y remove httpd-tools
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
systemctl enable httpd
systemctl start httpd

usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
cd /var/www/html
curl http://169.254.169.254/latest/meta-data/instance-id -o index.html
curl https://raw.githubusercontent.com/hashicorp/learn-terramino/master/index.php -O