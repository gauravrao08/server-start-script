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
	yum install -y wget curl traceroute telnet ;
 	yum groupinstall  -y "Development Tools";
 	yum install -y yum-utils  httpd openssl vim lynx openssl-devel;
	service httpd start && chkconfig httpd on ;	
	echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf;
        	echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf;
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
            	yum install -y php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-devel php-xml php-tidy php-mbstring php-intl php-pear php-bcmath php-redis php-imap php-tcpdf php-pecl-mongo php-pecl-mongodb php56-php-pecl-memcache php-pecl-memcache ;
            	error $? Php5.6_error
		sed -i 's/expose_php = On/expose_php = Off/g' /etc/php.ini;
            	printf "\n" | pecl install mongo;
                    	;;
     	php7.2)
            	echo "installing php7.2 version";
            	yum install --enablerepo=remi-php72 php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-devel php-xml php-tidy php-mbstring php-intl php-pear php-bcmath php-redis php-imap php-tcpdf composer -y
            	error $? php7.2_error
            	printf "\n" | pecl install mongodb;
	        yum install -y php-cli php-zip wget unzip ;
                php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" ;
                php composer-setup.php --install-dir=/usr/bin --filename=composer ;

         	       ;;
php7.4)
                echo "installing php7.4 version";
                yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm ;
                yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm ;
                yum -y install yum-utils
                yum-config-manager --enable remi-php74 ;
                #yum install -y php php-cli;
                yum install -y php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-devel php-xml php-tidy php-mbstring php-intl php-pear php-bcmath php-redis php-imap php-tcpdf php-pecl-memcache php74-php-pecl-mongodb php-mongodb.noarch ;
                                ;;



          	*)  
            	echo "Please define correct php version 5.4/5.6/7.2/7.4"
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
  #      yum -y install mysql redis;
 #	curl -sL https://rpm.nodesource.com/setup_11.x | sudo -E bash -;
 #	sudo yum -y install nodejs;
 #	npm install -g bower;
 #	npm install gulp -g;
 #	npm  install -g forever;
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

#memache package

other()
{       
        yum -y install memcached;
      #  service memcached start && chkconfig memcached on;
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

nvm()
{
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh |   NVM_DIR=/usr/local/nvm bash


cat >>/etc/profile.d/nvm.sh<<EOF
#!/usr/bin/env bash 
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
EOF

/etc/profile.d/nvm.sh
	#nvm install version
	#      npm install -g bower;
 #      npm install gulp -g;
 #      npm  install -g forever;

}



#:-script starting here
version=$1

if [ $# -ne 1 ]
then
echo "give all Argument like sh  $0 php{5.4,5.6,7.2,7.4}"
exit 1
fi
 

install
basicconfig
phpinstall
appserver
Db
useradd
other
nvm

echo "nvm install node_veersion"





