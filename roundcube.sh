#!/bin/bash


# Verificar si el usuario tiene permisos de root
if [ $(whoami) == "root" ]; then
	echo -e "Ets root."
else
	echo "No ets root."
	exit
fi

# Utilizar colores para resaltar la información
COLOR_ROJO='\033[0;31m'
COLOR_VERDE='\033[0;32m'
COLOR_NORMAL='\033[0m'


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

# Descargar Roundcube
echo -e "${COLOR_VERDE}Descargando Roundcube...${COLOR_NORMAL}"
wget https://github.com/roundcube/roundcubemail/releases/download/1.6.1/roundcubemail-1.6.1-complete.tar.gz > /dev/null 2>&1
echo -e "${COLOR_VERDE}Descarga completa.${COLOR_NORMAL}"

# Crear directorio de Roundcube
echo -e "${COLOR_VERDE}Creando directorio de Roundcube...${COLOR_NORMAL}"
mkdir -p /var/www/html/roundcube
echo -e "${COLOR_VERDE}Directorio creado.${COLOR_NORMAL}"

# Extraer archivos de Roundcube
echo -e "${COLOR_VERDE}Extrayendo archivos de Roundcube...${COLOR_NORMAL}"
tar xzf roundcubemail-1.6.1-complete.tar.gz -C /var/www/html/roundcube --strip-components 1 > /dev/null 2>&1
echo -e "${COLOR_VERDE}Extracción completa.${COLOR_NORMAL}"

# Configurar Roundcube
echo -e "${COLOR_VERDE}Configurando Roundcube...${COLOR_NORMAL}"
cp /var/www/html/roundcube/config/config.inc.php.sample /var/www/html/roundcube/config/config.inc.php
sed -i "s/\$config\['db_dsnw'\].*/\$config\['db_dsnw'\] = 'mysqli:\/\/$usuario@localhost\/roundcubedb';/" /var/www/html/roundcube/config/config.inc.php
echo -e "${COLOR_VERDE}Configuración completa.${COLOR_NORMAL}"

# Establecer permisos
echo -e "${COLOR_VERDE}Estableciendo permisos...${COLOR_NORMAL}"
chown -R www-data:www-data /var/www/html/roundcube
chmod -R 755 /var/www/html/roundcube
echo -e "${COLOR_VERDE}Permisos establecidos.${COLOR_NORMAL}"

# Redireccionamiento de salida estándar y error
echo "El script ha finalizado. Consulta el archivo log para más información."
echo "Gracias por utilizar este script." > /var/log/roundcube_instalacion.log 2>&1
