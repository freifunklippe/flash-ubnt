#!/bin/bash

# Description: Automated firmware flashing for Ubiquiti AC Mesh / AC Lite
# License: GPLv3
# by Collimas / www.freifunk-lippe.de / mb@freifunk-lippe.de
# Requirements: package 'sshpass' needs to be installed -> 'sudo apt install sshpass'
# Script needs to be executed with sudo privileges!

# functions

flashaclite() {
echo
echo "Der SSH-Key wird nun aktualisiert"
echo "-------------"
ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "192.168.1.20"
ssh-keyscan "192.168.1.20" >> "/home/$USER/.ssh/known_hosts"
echo "-------------"
echo "SSH-Key aktualisiert"
echo
echo
echo "Aktuelle Version des AP:"
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'cat /etc/version'
echo
echo "Obige Version muss 3.7.58 oder 3.8.3 sein. Wenn eine andere"
echo "Versionsnummer angezeigt wird, NICHT flashen !"
echo
echo "Beliebige Taste drücken - flashen" 
echo "STRG+C - Script abbrechen"
read -n 1 TASTE
sshpass -p 'ubnt' scp aclite.bin ubnt@192.168.1.20:/tmp 
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'mtd write /tmp/aclite.bin kernel0'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'mtd write /tmp/aclite.bin kernel1'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'dd if=/dev/zero bs=1 count=1 of=/dev/mtd$(cat /proc/mtd|grep bs|cut -c4)'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'reboot'
echo
echo "Der AP bootet nun und wird zur weiteren Konfiguration in Kürze "
echo "unter 192.168.1.1 erreichbar sein."
echo
printf "%s" "Warten auf Reboot im Config Mode ..."
while ! ping -c 1 -n -w 1 192.168.1.1 &> /dev/null
do
    printf "%c" "."
done
printf "\n%s\n"  "Knoten ist online im Config Mode"
echo "--------------------------------------------" >> nodes.txt
sshpass ssh root@192.168.1.1 'ip address show eth0 | grep -Eo [:0-9a-f:]{2}\(\:[:0-9a-f:]{2}\){5}' >> nodes.txt
echo "Schreibe SSH Key"
cat public_rsa_key.pub | sshpass ssh root@192.168.1.1 'cat >> /etc/dropbear/authorized_keys'
}



flashacmesh() {
echo
echo "Der SSH-Key wird nun aktualisiert"
echo "-------------"
ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "192.168.1.20"
ssh-keyscan "192.168.1.20" >> "/home/$USER/.ssh/known_hosts"
echo "-------------"
echo "SSH-Key aktualisiert"
echo
echo
echo "Aktuelle Version des AP:"
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'cat /etc/version'
echo
echo "Obige Version muss 3.7.58 oder 3.8.3 sein. Wenn eine andere"
echo "Versionsnummer angezeigt wird, NICHT flashen !"
echo
echo "Beliebige Taste drücken - flashen" 
echo "STRG+C - Script abbrechen"
read -n 1 TASTE
sshpass -p 'ubnt' scp acmesh.bin ubnt@192.168.1.20:/tmp 
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'mtd write /tmp/acmesh.bin kernel0'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'mtd write /tmp/acmesh.bin kernel1'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'dd if=/dev/zero bs=1 count=1 of=/dev/mtd$(cat /proc/mtd|grep bs|cut -c4)'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'reboot'
echo
echo "Der AP bootet nun und wird zur weiteren Konfiguration in Kürze "
echo "unter 192.168.1.1 erreichbar sein."
echo
printf "%s" "Warten auf Reboot im Config Mode ..."
while ! ping -c 1 -n -w 1 192.168.1.1 &> /dev/null
do
    printf "%c" "."
done
printf "\n%s\n"  "Knoten ist online im Config Mode"
echo "--------------------------------------------" >> nodes.txt
sshpass ssh root@192.168.1.1 'ip address show eth0 | grep -Eo [:0-9a-f:]{2}\(\:[:0-9a-f:]{2}\){5}' >> nodes.txt
echo "Schreibe SSH Key"
cat public_rsa_key.pub | sshpass ssh root@192.168.1.1 'cat >> /etc/dropbear/authorized_keys'
}

flashacmeshpro() {
echo
echo "Der SSH-Key wird nun aktualisiert"
echo "-------------"
ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "192.168.1.20"
ssh-keyscan "192.168.1.20" >> "/home/$USER/.ssh/known_hosts"
echo "-------------"
echo "SSH-Key aktualisiert"
echo
echo
echo "Aktuelle Version des AP:"
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'cat /etc/version'
echo
echo "Obige Version muss 3.7.58 oder 3.8.3 sein. Wenn eine andere"
echo "Versionsnummer angezeigt wird, NICHT flashen !"
echo
echo "Beliebige Taste drücken - flashen" 
echo "STRG+C - Script abbrechen"
read -n 1 TASTE
sshpass -p 'ubnt' scp acmeshpro.bin ubnt@192.168.1.20:/tmp 
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'mtd write /tmp/acmesh.bin kernel0'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'mtd write /tmp/acmesh.bin kernel1'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'dd if=/dev/zero bs=1 count=1 of=/dev/mtd$(cat /proc/mtd|grep bs|cut -c4)'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'reboot'
echo
echo "Der AP bootet nun und wird zur weiteren Konfiguration in Kürze "
echo "unter 192.168.1.1 erreichbar sein."
echo
printf "%s" "Warten auf Reboot im Config Mode ..."
while ! ping -c 1 -n -w 1 192.168.1.1 &> /dev/null
do
    printf "%c" "."
done
printf "\n%s\n"  "Knoten ist online im Config Mode"
echo "--------------------------------------------" >> nodes.txt
sshpass ssh root@192.168.1.1 'ip address show eth0 | grep -Eo [:0-9a-f:]{2}\(\:[:0-9a-f:]{2}\){5}' >> nodes.txt
echo "Schreibe SSH Key"
cat public_rsa_key.pub | sshpass ssh root@192.168.1.1 'cat >> /etc/dropbear/authorized_keys'
}

# main
clear
echo "Automatisiertes Firmware-Flashing für Ubiquiti AC Lite / AC Mesh Geräte"
echo "======================================================================="
echo
echo "Bitte diesen PC unter der IP-Adresse 192.168.1.20/24 erreichbar"
echo "machen und Ubiquiti Hardware mit dem Netzwerk verbinden."
echo "Der Netzwerkschnittstelle eth0 wird automatisch eine Adresse aus"
echo "diesem Subnet hinzugefügt."
echo
echo "Die zu flashende Firmware muss unter dem Dateinamen acmesh.bin,"
echo "acmeshpro.bin oder aclite.bin im Verzeichnis dieses Scriptes liegen."
echo "Die notwendigen Images werden jetzt automatisch heruntergeladen."
echo
echo
wget -nc http://download.freifunk-lippe.de/flash-ubnt/*.*
ifconfig eth0:0 192.168.1.254 netmask 255.255.255.0 up
PS3='Bitte wählen: '
options=("Flashen AC Lite" "Flashen AC Mesh" "Flashen AC Mesh Pro" "Beenden")
select opt in "${options[@]}"
do
    case $opt in
        "Flashen AC Lite")
            echo
            echo "AC Lite wurde ausgewählt"
            flashaclite
            ;;
        "Flashen AC Mesh")
            echo
            echo "AC Mesh wurde ausgewählt"
            flashacmesh
            ;;
        "Flashen AC Mesh Pro")
            echo
            echo "AC Mesh Pro wurde ausgewählt"
            flashacmeshpro
            ;;
        "Beenden")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
