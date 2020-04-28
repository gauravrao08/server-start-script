# server-start-script
server start script
```
#!/bin/bash



#:-error_check

error()
{
 	status=$1
 	if [ $status -ne 0 ]
 	then echo "Error: in $2"
 	exit 1
 	fi
}

#:- install packages

install()
{

#:-basic packages
 	yum update -y ; yum install epel-release -y;
 	yum groupinstall  -y "Development Tools";
 	yum install -y yum-utils  httpd openssl vim lynx openssl-devel;
	service httpd start && chkconfig httpd on ;	
 	error $?  basic_installation
}

#:- basic configration

basicconfig()
{

#:- disable selinux 

 	sed -i 's/enforcing/disabled/g' /etc/selinux/config;
	setenforce 0;

#:-date and time 

 	mv /etc/localtime  /etc/localtime_bkp
 	ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
 	error $? basic_config

}


#:-install php 

phpinstall()
{
 
   case $version in
     	php5.4)
     	 
            	echo "installing php5.4"
     		 yum install -y php php-pear php-devel php-gd php-bcmath php-intl;
     		 error $? php5.4_error
            	printf "\n" | pecl install mongo;
		pecl install channel://pecl.php.net/redis-2.2.8 -y; 
       			 ;;

   	  php5.6)
            	echo "installing php5.6"
            	yum install -y  http://rpms.remirepo.net/enterprise/remi-release-7.rpm ;
            	yum-config-manager --enable remi-php56;
            	yum install -y php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-devel php-xml php-tidy php-mbstring php-intl php-pear php-bcmath php-imap php-tcpdf;
            	error $? php5.6_error
            	printf "\n" | pecl install mongo;
                    	;;
     	php7.2)
            	echo "installing php7.2 version";
            	yum install --enablerepo=remi-php72 php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo composer -y
            	error $? php7.2_error
            	printf "\n" | pecl install mongodb;
	        yum install -y php-cli php-zip wget unzip ;
                php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" ;
                php composer-setup.php --install-dir=/usr/bin --filename=composer ;

         	       ;;

          	*)  
            	echo "Please define correct php version 5.4/5.6/7.2"
            	exit 1
          			 ;;
   esac

}

#:- app server installation 

appserver()
{
 
#####nodejs##
 	yum install -y gcc-c++ make;
        pecl install channel://pecl.php.net/redis-2.2.8 -y;
        echo "php  installed";
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php composer-setup.php --install-dir=/usr/bin --filename=composer;

        echo "composer installed";
        yum -y install mysql redis;
 	curl -sL https://rpm.nodesource.com/setup_11.x | sudo -E bash -;
 	sudo yum -y install nodejs;
 	npm install -g bower;
 	npm install gulp -g;
 	npm  install -g forever;
 	error $? npm_installation

}


#:- database

Db()
{

 	yum install -y mysql redis;

##mongo
	echo "[mongodb-org-3.4]" >> /etc/yum.repos.d/mongodb-org-3.4.repo ;
 	echo "name=MongoDB Repository" >> /etc/yum.repos.d/mongodb-org-3.4.repo;
 	echo "baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/" >> /etc/yum.repos.d/mongodb-org-3.4.repo;
 	echo  "gpgcheck=1" >> /etc/yum.repos.d/mongodb-org-3.4.repo;
 	echo  "enabled=1" >> /etc/yum.repos.d/mongodb-org-3.4.repo;
 	echo  "gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc"  >>  /etc/yum.repos.d/mongodb-org-3.4.repo ;
   
   	yum install -y mongodb-org ;
	 

   	error $? db_configuration



}


useradd()
{

if [ ! -d  /data ];
then  mkdir /data;
fi
chmod 755 /data;
/sbin/useradd deployer;
cd /home/;
mv deployer /data/ ;
ln -s /data/deployer/ .  ;

chown -h deployer:deployer deployer ;
chmod 755 /home/deployer ;
usermod -a -G apache deployer ;

mkdir  /data/config ;
chown deployer:deployer /data/config ;
cd /var/ ;
ln -s /data/config . ;
chown -h deployer:deployer config ;

error $? useradd

}





#:-script starting here
version=$1

if [ $# -ne 1 ]
then
echo "give all Argument like sh  $0 php{5.4,5.6,7.2}"
exit 1
fi
 

install
basicconfig
phpinstall
appserver
Db
useradd


```
