#!/bin/bash
clear

#Comprovem usuari
if [ $(whoami) == "root" ]; then
	echo -e "Ets root."
else
	echo "No ets root."
	exit
fi

#Uptade
apt-get update >/dev/null

#Instal.lació paquet Apache2
if [ $(dpkg-query -W -f='${Status}' 'apache2' | grep -c "ok installed") -eq 0 ];then 
	echo "Apache2 no està instal.lat" >/script/registre.txt
	apt-get -y install apache2 >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "Apache2 instal.lat correctament." >>/script/registre.txt
		echo "Apache2 instal.lat correctament."
	else
		echo "Apache2 instal.lat incorrectament."
	fi
else
	echo "Apache2 està instal.lat"
fi

#Instal.lació paquet mariadb-server
if [ $(dpkg-query -W -f='${Status}' 'mariadb-server' | grep -c "ok installed") -eq 0 ];then 
	echo "Mariadv-server no està instal.lat"
	apt-get -y install mariadb-server >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "Mariadb-server instal.lat correctament." >>/script/registre.txt
		echo "Mariadb-server instal.lat correctament."
	else
		echo "Mariadb-server instal.lat incorrectament."
	fi
else
	echo "Mariadb-server està instal.lat"
fi

#Instal.lació paquet php
if [ $(dpkg-query -W -f='${Status}' 'php' | grep -c "ok installed") -eq 0 ];then 
	echo "PHP no està instal.lat"
	apt-get -y install php >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "PHP instal.lat correctament." >>/script/registre.txt
		echo "PHP instal.lat correctament."
	else
		echo "PHP instal.lat incorrectament."
	fi
else
	echo "php està instal.lat"
fi

#Instal.lació paquet php-mysql
if [ $(dpkg-query -W -f='${Status}' 'php-mysql' | grep -c "ok installed") -eq 0 ];then 
	echo "php-mysql no està instal.lat"
	apt-get -y install php-mysql >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "php-mysql instal.lat correctament." >>/script/registre.txt
		echo "php-mysql instal.lat correctament."
	else
		echo "php-mysql instal.lat incorrectament."
	fi
else
	echo "php-mysql està instal.lat"
fi


#Comprovem si la base de dades moodle existeix
dbname="moodle"
if [ -d "/var/lib/mysql/$dbname" ]; then
	echo "La base de dades existeix"
else
	echo "La base de dades no existeix"
	mysql -u root -e "CREATE DATABASE moodle;"
	mysql -u root -e "CREATE USER 'moodle'@'localhost' IDENTIFIED BY 'moodle';"
	mysql -u root -e "GRANT ALL PRIVILEGES ON moodle .* TO 'moodle'@'localhost';"
	mysql -u root -e "FLUSH PRIVILEGES;"
	mysql -u root -e "exit"
	echo "La base de dades moodle s'ha creat correctament"
fi

cd /opt/
wget https://download.moodle.org/download.php/direct/stable401/moodle-latest-401.tgz
tar zxvf moodle-latest-401.tgz
rm /vat/www/html/index.html
mv moodle/* /var/www/html/
mkdir /var/www/moodledata
chmod -R 755 /var/www/
chown -R www-data:www-data /var/www/

#Cal fer control d'errors a totes les setències