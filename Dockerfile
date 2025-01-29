#pull base image
FROM ubuntu
#update the system
RUN apt-get update
#install reqiured packages
RUN apt-get install -y apache2
RUN apt-get install -y systemctl
RUN apt-get install -y vim
#copying the webpage for apache2
COPY index.html /var/www/html/

#Start the tomcate service and enable
RUN systemctl start apache2
RUN systemctl enable apache2

#COPY index.html /var/www/html/
#apt-get install -y  curl 
