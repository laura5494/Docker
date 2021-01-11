# Imagen del contenedor que ejecuta tu código
FROM ubuntu:20.04

MAINTAINER Odoo S.A. <info@odoo.com>

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8
  #Update Server
  RUN  apt-get update && upgrade -y
  #Create Odoo User in Ubuntu
  
 #Install PostgreSQL Server
  RUN sudo adduser -system -home=/opt/odoo -group odoo
  
 #Install PostgreSQL Server
  RUN sudo apt-get install postgresql -y
  
  #Create Odoo user for PostgreSQL
  RUN sudo su - postgres -c "createuser -s odoo" 2> /dev/null || true
  
  #COPY odoo.deb .
 #RUN set -x; \
         # dpkg --force-depends -i odoo.deb \
         # && apt-get update \
          #&& apt-get -y install -f --no-install-recommends \
          #&& rm -rf odoo.deb
         
#Install Python Dependencies
RUN sudo apt-get install git python3 python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev gdebi -y

#Install Python PIP Dependencies
RUN sudo apt-get install libpq-dev python-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libffi-dev
RUN sudo -H pip3 install -r https://raw.githubusercontent.com/odoo/odoo/master/requirements.txt
                                     
#Install other required packages
RUN sudo apt-get install nodejs npm -y                         
  RUN npm install -g rtlcss
  
#Install Wkhtmltopdf                       
RUN sudo apt-get install xfonts-75dpi
RUN sudo wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb                        
RUN sudo dpkg -i wkhtmltox_0.12.6-1.bionic_amd64.deb                                           
RUN sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage
RUN sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf

#Create Log directory                                                                       
RUN sudo mkdir /var/log/odoo                                           
RUN sudo chown odoo:odoo /var/log/odoo
   
#Install Odoo  
                        
RUN sudo apt-get install git
                                            
RUN sudo git clone --depth 1 --branch 14.0 https://www.github.com/odoo/odoo /odoo/odoo-server
 
 #Setting permissions on home folder    
 RUN sudo chown -R odoo:odoo /odoo/*
 
 #Create server config file
 
                         
RUN sudo touch /etc/odoo-server.conf
                                            
RUN sudo su root -c "printf '[options] \n; This is the password that allows database operations:\n' >> /etc/odoo-server.conf"
RUN sudo su root -c "printf 'admin_passwd = admin\n' >> /etc/odoo-server.conf"
RUN sudo su root -c "printf 'xmlrpc_port = 8069\n' >> /etc/odoo-server.conf"
RUN sudo su root -c "printf 'logfile = /var/log/odoo/odoo-server.log\n' >> /etc/odoo-server.conf"
RUN sudo su root -c "printf 'addons_path=/odoo/odoo-server/addons\n' >> /etc/odoo-server.conf"
RUN sudo chown odoo:odoo /etc/odoo-server.conf
RUN sudo chmod 640 /etc/odoo-server.conf

#Now Start Odoo
                        
#RUN sudo su - odoo -s /bin/bash
 #RUN      cd /odoo/odoo-server
#RUN    ./odoo-bin -c /etc/odoo-server.conf
 
 # Copy entrypoint script and Odoo configuration file
 
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER root

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
                    
                    
