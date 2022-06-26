### Launch configuration for wordpress instance
resource "aws_launch_configuration" "server_conf" {
  name_prefix                 = "wordpress sever configuration"
  image_id                    = "ami-0cff7528ff583bf9a"
  instance_type               = "t2.micro"
  key_name                    = "key2"
  security_groups             = [aws_security_group.wordpress_sg.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp2"
    volume_size = 16
    encrypted   = false
  }
  user_data =<<-EOF
  #!/bin/bash
#mount efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.wordpress_efs.dns_name}:/ /var/www/html

#install the apache webserver
sudo yum install -y httpd
sudo systemctl enable httpd

#install application dependecies
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

# download and configure wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo systemctl restart httpd
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/${var.database_name}/g" wp-config.php
sudo sed -i "s/username_here/${var.database_user}/g" wp-config.php
sudo sed -i "s/password_here/${var.database_password}/g" wp-config.php
sudo sed -i "s/localhost/${aws_db_instance.wordpress_db.endpoint}/g" wp-config.php

# create database user for your WordPress application 
export MYSQL_HOST=${aws_db_instance.wordpress_db.endpoint}
mysql --user=${var.database_user} --password=${var.database_password} ${var.database_name}
CREATE USER '${var.database_user}' IDENTIFIED BY '${var.database_password}';
CREATE USER '${var.database_user}' IDENTIFIED BY '${var.database_password}';
GRANT ALL PRIVILEGES ON ${var.database_name}.* TO ${var.database_user};
FLUSH PRIVILEGES;
Exit

# change permision of /var/www/html directory
sudo chown -R ec2-user:apache /var/www/html
sudo chmod -R 755 /var/www/html
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;

# restart apache
sudo systemctl restart httpd
  EOF
  
  depends_on = [aws_security_group.wordpress_sg]
}
