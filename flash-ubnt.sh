#!/bin/bash

# Description: Automated firmware flashing for Ubiquiti AC Mesh (Pro) / AC Lite
# License: GPLv3
# by Collimas / www.freifunk-lippe.de / michael.brinkmann@freifunk-lippe.de
# Requirements: package 'sshpass' needs to be installed -> 'sudo apt install sshpass'

# functions

flashaclite() {
#
# SSH-Key aktualisieren
#
echo
echo "Der SSH-Key wird nun aktualisiert"
echo "-------------"
ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "192.168.1.20"
ssh-keyscan "192.168.1.20" >> "/home/$USER/.ssh/known_hosts"
echo "-------------"
echo "SSH-Key aktualisiert"
#
# Flashtool von Ubiquiti kopieren
#
echo "Kopiere mtd..."
sshpass -p 'ubnt' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null mtd ubnt@192.168.1.20:/bin
#
# Firmware herunterladen
#
echo "Lade Firmware"
wget -N "http://download.freifunk-lippe.de/flash-ubnt/aclite.bin"
#
# Firmware per SCP nach /tmp auf dem Target kopieren
#
sshpass -p 'ubnt' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null aclite.bin ubnt@192.168.1.20:/tmp
#
# Firmware flashen
#
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'mtd write /tmp/aclite.bin kernel0'
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'mtd write /tmp/aclite.bin kernel1'
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'dd if=/dev/zero bs=1 count=1 of=/dev/mtd$(cat /proc/mtd|grep bs|cut -c4)'
#
# Router neu starten
#
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'reboot'
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
echo "30 Sekunden warten..."
sleep 30
echo "--------------------------------------------" >> nodes.txt
#
# MAC-Adresse auslesen und in nodes.txt schreiben
#
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'ip address show eth0 | grep -Eo [:0-9a-f:]{2}\(\:[:0-9a-f:]{2}\){5}' >> nodes.txt
#
# Konfigurationseinstellungen setzen
#
echo "Schreibe SSH Key und Knoteninfos"
cat public_rsa_key.pub | sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'cat >> /etc/dropbear/authorized_keys'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'pretty-hostname FFBSU'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci set gluon-node-info.@owner[0].contact=info@freifunk-lippe.de'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci commit gluon-node-info'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci set gluon.core.domain=d4low'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci commit'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'gluon-reconfigure'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci set gluon-setup-mode.@setup_mode[0].configured=1'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci commit gluon-setup-mode'
echo "Knoten ist fertig geflasht und rebootet nun."
#
# Fertig!
#
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'reboot'
read -p "Bitte drücke ENTER um zum Menü zurückzukehren."
menu
}

flashacmesh() {
echo
echo "Der SSH-Key wird nun aktualisiert"
echo "-------------"
ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "192.168.1.20"
ssh-keyscan "192.168.1.20" >> "/home/$USER/.ssh/known_hosts"
echo "-------------"
echo "SSH-Key aktualisiert"
echo "Kopiere mtd..."
sshpass -p 'ubnt' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null mtd ubnt@192.168.1.20:/bin
echo "Lade Firmware"
wget -N "http://download.freifunk-lippe.de/flash-ubnt/acmesh.bin"
sshpass -p 'ubnt' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null acmesh.bin ubnt@192.168.1.20:/tmp
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'mtd write /tmp/acmesh.bin kernel0'
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'mtd write /tmp/acmesh.bin kernel1'
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'dd if=/dev/zero bs=1 count=1 of=/dev/mtd$(cat /proc/mtd|grep bs|cut -c4)'
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'reboot'
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
echo "30 Sekunden warten..."
sleep 30
echo "--------------------------------------------" >> nodes.txt
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'ip address show eth0 | grep -Eo [:0-9a-f:]{2}\(\:[:0-9a-f:]{2}\){5}' >> nodes.txt
echo "Schreibe SSH Key und Knoteninfos"
cat public_rsa_key.pub | sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'cat >> /etc/dropbear/authorized_keys'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'pretty-hostname FFBSU'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci set gluon-node-info.@owner[0].contact=info@freifunk-lippe.de'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci commit gluon-node-info'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci set gluon.core.domain=d4low'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci commit'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'gluon-reconfigure'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci set gluon-setup-mode.@setup_mode[0].configured=1'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci commit gluon-setup-mode'
echo "Knoten ist fertig geflasht und rebootet nun."
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'reboot'
read -p "Bitte drücke ENTER um zum Menü zurückzukehren."
menu
}

flashacmeshpro() {
echo
echo "Der SSH-Key wird nun aktualisiert"
echo "-------------"
ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "192.168.1.20"
ssh-keyscan "192.168.1.20" >> "/home/$USER/.ssh/known_hosts"
echo "-------------"
echo "SSH-Key aktualisiert"
echo "Kopiere mtd..."
sshpass -p 'ubnt' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null mtd ubnt@192.168.1.20:/bin
echo "Lade Firmware"
wget -N "http://download.freifunk-lippe.de/flash-ubnt/acmeshpro.bin"
sshpass -p 'ubnt' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null acmeshpro.bin ubnt@192.168.1.20:/tmp
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'mtd write /tmp/acmeshpro.bin kernel0'
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'mtd write /tmp/acmeshpro.bin kernel1'
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'dd if=/dev/zero bs=1 count=1 of=/dev/mtd$(cat /proc/mtd|grep bs|cut -c4)'
sshpass -p 'ubnt' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubnt@192.168.1.20 'reboot'
read -p "Bitte Netzwerkkabel auf den Secondary Port umstecken und ENTER drücken."
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
echo "45 Sekunden warten..."
sleep 45
echo "--------------------------------------------" >> nodes.txt
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'ip address show eth0 | grep -Eo [:0-9a-f:]{2}\(\:[:0-9a-f:]{2}\){5}' >> nodes.txt
echo "Schreibe SSH Key und Knoteninfos"
cat public_rsa_key.pub | sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'cat >> /etc/dropbear/authorized_keys'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'pretty-hostname FFBSU'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci set gluon-node-info.@owner[0].contact=info@freifunk-lippe.de'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci commit gluon-node-info'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci set gluon.core.domain=d4low'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci commit'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'gluon-reconfigure'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci set gluon-setup-mode.@setup_mode[0].configured=1'
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'uci commit gluon-setup-mode'
echo "Knoten ist fertig geflasht und rebootet nun."
sshpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1 'reboot'
read -p "Bitte drücke ENTER um zum Menü zurückzukehren."
menu
}

menu() {
clear
echo "Automatisiertes Firmware-Flashing für Ubiquiti AC Lite / AC Mesh Geräte"
echo "======================================================================="
echo
echo "Bitte diesen PC unter der IP-Adresse 192.168.1.20/24 erreichbar"
echo "machen und Ubiquiti Hardware mit dem Netzwerk verbinden."
echo
echo "Die zu flashende Firmware muss unter dem Dateinamen acmesh.bin,"
echo "acmeshpro.bin oder aclite.bin im Verzeichnis dieses Scriptes liegen."
echo
echo
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
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
}

# main

menu
