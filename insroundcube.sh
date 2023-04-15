#!/bin/bash

# Verificar si el usuario tiene permisos de root
if [ $(whoami) == "root" ]; then
	echo -e "\033[0;32mEts root.\033[0m"
else
	echo -e "\033[0;31mNo ets root.\033[0m"
	exit
fi

# Utilizar colores para resaltar la información
COLOR_ROJO='\033[0;31m'
COLOR_VERDE='\033[0;32m'
COLOR_NORMAL='\033[0m'

# Avisar antes de actualizar
echo -e "${COLOR_VERDE}Actualizando el sistema...${COLOR_NORMAL}"
# Uptade
apt-get update >/dev/null
echo -e "${COLOR_VERDE}Actualización completa.${COLOR_NORMAL}"

# Avisar antes de instalar Apache2
echo -e "${COLOR_VERDE}Instalando paquete Apache2...${COLOR_NORMAL}"
# Instal.lació paquet Apache2
if [ $(dpkg-query -W -f='${Status}' 'apache2' | grep -c "ok installed") -eq 0 ];then 
	echo "Apache2 no està instal.lat" >/script/registre.txt
	apt-get -y install apache2 >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "Apache2 instal.lat correctament." >>/script/registre.txt
		echo -e "${COLOR_VERDE}Apache2 instalado correctamente.${COLOR_NORMAL}"
	else
		echo -e "${COLOR_ROJO}Error al instalar Apache2.${COLOR_NORMAL}"
	fi
else
	echo -e "${COLOR_VERDE}Apache2 ya está instalado.${COLOR_NORMAL}"
fi

# Avisar antes de instalar Mariadb-server
echo -e "${COLOR_VERDE}Instalando paquete Mariadb-server...${COLOR_NORMAL}"
# Instal.lació paquet mariadb-server
if [ $(dpkg-query -W -f='${Status}' 'mariadb-server' | grep -c "ok installed") -eq 0 ];then 
	echo "Mariadv-server no està instal.lat"
	apt-get -y install mariadb-server >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "Mariadb-server instal.lat correctament." >>/script/registre.txt
		echo -e "${COLOR_VERDE}Mariadb-server instalado correctamente.${COLOR_NORMAL}"
	else
		echo -e "${COLOR_ROJO}Error al instalar Mariadb-server.${COLOR_NORMAL}"
	fi
else
	echo -e "${COLOR_VERDE}Mariadb-server ya está instalado.${COLOR_NORMAL}"
fi

# Avisar antes de instalar PHP
echo -e "${COLOR_VERDE}Instalando paquete PHP...${COLOR_NORMAL}"
# Instal.lació paquet php
if [ $(dpkg-query -W -f='${Status}' 'php' | grep -c "ok installed") -eq 0 ];then 
	echo "PHP no està instal.lat"
	apt-get -y install php >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo "PHP instal.lat correctament." >>/script/registre.txt
		echo -e "${COLOR_VERDE}PHP instalado correctamente.${COLOR_NORMAL}"
	else
		echo -e "${COLOR_ROJO}Error al instalar PHP.${COLOR_NORMAL}"
	fi
else
	echo -e "${COLOR_VERDE}PHP ya está instalado.${COLOR_NORMAL}"
fi

# Descargar Roundcube
echo -e "${COLOR_VERDE}Descargando Roundcube...${COLOR_NORMAL}"
wget https://github.com/roundcube/roundcubemail/releases/download/1.4.12/roundcubemail-1.4.12-complete.tar.gz -P /tmp/ > /dev/null 2>&1

# Descomprimir y mover Roundcube
echo -e "${COLOR_VERDE}Descomprimiendo Roundcube...${COLOR_NORMAL}"
tar -xzf /tmp/roundcubemail-1.4.12-complete.tar.gz -C /tmp/ > /dev/null 2>&1
mv /tmp/roundcubemail-1.4.12 /var/www/html/roundcube > /dev/null 2>&1

# Configurar Roundcube
echo -e "${COLOR_VERDE}Configurando Roundcube...${COLOR_NORMAL}"
cp /var/www/html/roundcube/config/config.inc.php.sample /var/www/html/roundcube/config/config.inc.php > /dev/null 2>&1
sed -i "s/'sqlite',/'mysql',/g" /var/www/html/roundcube/config/config.inc.php > /dev/null 2>&1
sed -i "s/'localhost'/'$MYSQL_HOST'/g" /var/www/html/roundcube/config/config.inc.php > /dev/null 2>&1
sed -i "s/'roundcube'/'$MYSQL_USER'/g" /var/www/html/roundcube/config/config.inc.php > /dev/null 2>&1
sed -i "s/'password'/'$MYSQL_PASSWORD'/g" /var/www/html/roundcube/config/config.inc.php > /dev/null 2>&1

# Crear base de datos
echo -e "${COLOR_VERDE}Creando base de datos para Roundcube...${COLOR_NORMAL}"
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE IF NOT EXISTS roundcubedb;" > /dev/null 2>&1
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON roundcubedb.* TO '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" > /dev/null 2>&1

# Importar esquema
echo -e "${COLOR_VERDE}Importando esquema de la base de datos de Roundcube...${COLOR_NORMAL}"
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD roundcubedb < /var/www/html/roundcube/SQL/mysql.initial.sql > /dev/null 2>&1

# Cambiar permisos de Roundcube
echo -e "${COLOR_VERDE}Cambiando permisos de Roundcube...${COLOR_NORMAL}"
chown -R www-data:www-data /var/www/html/roundcube > /dev/null 2>&1
echo -e "${COLOR_VERDE}Roundcube instalado y configurado correctamente${COLOR_NORMAL}"
