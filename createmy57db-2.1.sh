#!/bin/bash
#
#
###########-----createmy57db-2.1-----############
#						#
#      		Creado por 			#
#	  joaquín Alexander Ruíz  		#
#        j.ruizc@uniandes.edu.co 		#
#	 Universidad de los Andes 		#
#	     Bogota colombia 			#
#						#
#################################################
#
#								
#########################################################
#	            CONFIGURACIÓN    			#
#							#
#  Usuario con privilegios sobre la db			#
#  user="usuariodb"					#
user="paco"						#
#							#
#  Contraseña del usuario de la db			#
#  pass="password" 					#
pass="mypaco1.."					#
#							#
#  Ruta de la instancia MySql				#
#  ruta="/mysql/mysql5725/bin/"				#
ruta=""							#
#							#
#  Opciones de socket					#
#  socket="-S /mysql/mysql_files/serv_3306.sock" 	#
socket=""					   	#
#						   	#
# Loguearse automaticamente? yes/no   logon="no"	#
logon="no"						#
#							#
#########################################################
#
#
#
dia=$(date +%Y-%m-%d)
hora=$(date +%H:%M)
flog="createmy57db.log"						
npru=3
if [ ! -d log ]
then
       	clear	
	echo -e "Instalando..." "\n"
	if [ $(id -u) = 0 ]
	then
		echo "Creando carpeta..."
		mkdir log
		echo "Creando archivos..."
		touch log/$flog log/$flog.csv
		echo "Modificando archivos..."
		echo "Fecha;Hora;Usuario;NewBase;NewUser" >> "log/$flog.csv"
		echo "Cambiando permisos..."
		chmod 660 log/*
		chown opermysql log/*
		chgrp opermysql log/*
		chmod 550 "createmy57db-2.1.sh"
		chown root "createmy57db-2.1.sh"
		chgrp opermysql "createmy57db-2.1.sh"
		chmod 1655 log
		chgrp opermysql log
		echo -e "Instalación completa. " "\n\n"
	else
		echo -e  "Debe ejecutarse como root para poder instalar" "\n\n"
		exit 1
	fi
exit 1
fi
flogin() {
if [ $logon = "no" ]
then
	echo -e "Ingrese los datos de autenticación:" "\n"
#	read -e -i "$user" -p "Usuario: " user2
#	user="${user2:-$user}"
	read -p "Usuario: " user
	read -p "Contraseña: " -s pass
elif [ $logon != "yes" ]
then 
	echo "Error en la configuración logon"
	echo ""
	exit 1
fi
}
fpru() {
		ftitle
		$ruta"mysql" -u$user -p$pass $socket -e "exit"
		p="$?"
		ftitle
		if [ $p = 0 ]  
			then
			ftitle
			echo -e " Conexion establecida." "\n"
		else	
			ftitle		
			echo -e "Quedan $npru intentos." "\n\n"
			if [ $npru -eq 0 ]
			then 
				ftitle
				ffin
				exit 1
			fi
			let npru-=1
			flogin
			fpru
		fi
}	
flistdb() {
 	$ruta"mysql""show" -u$user -p$pass $socket "$db"
	prudb="$?"
}
fdb() {
	db=x
	read -p " Nombre de la db a crear: " db
	flistdb
	ftitle
	if [ $prudb = 1 ]
	then
		echo -e "Se ejecutara el comando:\n"
		echo CREATE DATABASE $db /*!40100 COLLATE "'"latin1_spanish_ci"'" */";"
		echo -e "\n\n"
		while :
		do
		read -p "¿Desea crear la base de datos? s/n: " x
		case $x in
		s|S)
			ftitle
			echo -e "\nCreando la base de datos '$db' ...."
			$ruta"mysql" -u$user -p$pass $socket -e "CREATE DATABASE $db /*!40100 COLLATE 'latin1_spanish_ci' */"	
			flistdb
			ftitle		
				if [ $prudb = 0 ]
				then 
					echo -e "Base de datos creada!!!" "\n"
					echo $dia";"$hora";"$user";"$db >> "log/$flog.csv"
					echo $dia $hora $user" Newdb:"$db >> "log/$flog"
					$ruta"mysql" -u$user -p$pass $socket -e "show databases like '$db'"
					read -p "Presione cualquier teclar para continuar..." d
				else
					read -p "Error en la creacion de la base de datos." "Presione cualquier tecla para continuar." d
				fi
			break;;
			n|N)
				fmenu
			break;;	
			*)
				echo Digite una opcion valida.;;
			esac	
		done
	else
		$ruta"mysql" -u$user -p$pass $socket -e "show databases like '$db'"
		echo -e "\n" "Base de datos existente!!!" "\n\n Ingrese un nombre distinto para la nueva base de datos." "\n"
		fdb
	fi
}
fasig() {
	userperm="SELECT, ALTER, CREATE, CREATE VIEW, DELETE, DROP, INDEX, INSERT, UPDATE, LOCK TABLES"
	echo -e "Asignación de permisos para el usuario $newuser." "\n\n"
	read -e -i "$userperm" -p "Ingrese los permisos: " userperm2
	userperm="${userperm2:-$userperm}"
	echo -e "\n"		
	read -e -i "$db" -p "Base de datos sobre la cual va a tener permisos: " db2
	db="${db2:-$db}"
	ftitle
	echo -e "Se ejecutaran los siguientes comandos:""\n\n"
	echo GRANT USAGE ON "*.*" TO "'"$newuser"'@'"$newhost"';"
	echo ""
	echo GRANT $userperm ON $db TO "'"$newuser"'@'"$newhost"';"
	echo -e "\nset old passwords=FALSE\n"
	echo set password for "'"$newuser"'@'"$newhost"'" = password"('****');"
	echo -e "\nFLUSH PRIVILEGES;""\n\n\n"
	while :
	do
		read -p "¿Esta seguro de asignar dichos permisos? s/n : " x
		case $x in
		s|S)
			ftitle
			echo GRANT USAGE ON "*.*" TO "'"$newuser"'@'"$newhost"';"
			$ruta"mysql" -u$user -p$pass $socket -e "grant usage on *.* to '$newuser'@'$newhost'"
			echo -e"\n"
			echo GRANT $userperm ON $db TO "'"$newuser"'@'"$newhost"';"
			$ruta"mysql" -u$user -p$pass $socket -e "grant $userperm on $db .* to '$newuser'@'$newhost'"
			echo -e"\n"
			echo "set old passwords=FALSE"
			$ruta"mysql" -u$user -p$pass $socket -e "set old_passwords=FALSE"
			echo -e"\n"
			echo set password for "'"$newuser"'@'"$newhost"'" = password"('****');"
			$ruta"mysql" -u$user -p$pass $socket -e "set password for '$newuser'@'$newhost' = password('$newpass')"
			echo "\n"
			echo -e "FLUSH PRIVILEGES;""\n"
			$ruta"mysql" -u$user -p$pass $socket -e "FLUSH PRIVILEGES"	
			fmenu;;
		n|N)
			ftitle
			fasig;;
		*)
			echo Digite una opción valida.;;
		esac
	done
}
fnewuser() {
	newuser=x
	newpass=x
	newhost=157.253.50.%
	read -p "Ingrese el nombre de usuario a crear: " newuser
	mysql -u$user -p$pass -e "select user from mysql.user " > lista1567.ft
	grep "$newuser" lista1567.ft
	prus="$?"
	rm lista1567.ft
	ftitle
		if [ $prus = 0 ]
		then	
			ftitle
			echo -e "Usuario existente!!!" "\n""Escriba otro nombre de usuario."
			fnewuser
		fi
		read -p "Ingrese la contraseña para el usuario '$newuser': " newpass
		read -e -i "$newhost" -p "Ingrese el host desde el que puede ingresar: " newhost2
		newhost="${newhost2:-$newhost}"
		ftitle
		echo -e "Se ejecutara el siguiente comando:""\n\n"
		echo -e "CREATE USER '$newuser'@'$newhost' IDENTIFIED BY '****'\n"
		while :
		do
			read -p "¿Desea crear el usuario? s/n : " x
			case $x in
		s|S)
			mysql -u$user -p$pass -e "create user '$newuser'@'$newhost' IDENTIFIED BY '$newpass'"
			echo $dia";"$hora";"$user";;"$newuser >> "log/$flog.csv"
			echo $dia $hora $user" NewUser:"$newuser >> "log/$flog"
			ftitle
			echo -e "Usuario $newuser creado!!!" "\n\n"
			mysql -u$user -p$pass -e "select user from mysql.user where user like '$newuser'" 
			echo ""
			read -p "Presione enter para continuar..." p
			ftitle
			fasig;;
		n|N)
			fmenu;;
		*)
			echo Digite una opción valida.;;
		esac
	done
}
ftitle(){
	clear
	echo "   ________________________________________________"
	echo "  | CREACION DE BASES DE DATOS Y USUARIOS EN MYSQL |"
	echo "  |              createmy57db v2.1                 |"
	echo "  |________________________________________________|"
	echo -e "\n"
}
ffin(){ 
	echo ""
	echo "	 	   ____________________________" 
	echo "  	  |  Universidad de los Andes  |" 
	echo "  	  |      Bogotá Colombia       |" 
	echo "  	  |____________________________|" 
	echo -e "\n"
}
fmenu() {
	ftitle
if [ $(id -u) = 0 ]
then
	echo "  Createmy57db-2.1 no puede ser ejecutado como root!!"
	echo ""
	echo "  Ingrese con el usuario 'opermysql'."
	ffin
	exit 1
fi
	echo "Que desea hacer?"
	select x in 'Crear base de datos' 'Crear usuario' 'Crear db y usuario' 'Salir'
	do
		case $x in
		"Crear base de datos") 
			ftitle
			flogin
			fhst
			fpru
			fdb
			fmenu
			ftitle
			;;
		"Crear usuario")
			ftitle
			flogin
			fhst
			fpru
			ftitle
			fnewuser
			ftitle
			fasig
			ftitle;;
		"Crear db y usuario")
			ftitle
			flogin
			fhst
			fpru
			fdb
			ftitle
			fnewuser
			ftitle
			fasig
			ftitle;;
		
		"Salir")
			ffin	
			exit 1;;
		*) 
			echo Digite una opcion valida;;	
		esac
	done
}
fmenu
