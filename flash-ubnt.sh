#!/bin/bash

# Description: Automated firmware flashing for Ubiquiti AC Mesh / AC Lite
# License: GPLv3
# by Collimas / www.freifunk-lippe.de / mb@freifunk-lippe.de
# Requirements: package 'sshpass' needs to be installed -> 'sudo apt install sshpass'

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
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'dd if=/dev/zero bs=1 count=1 of=/dev/mtd4'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'reboot'
echo
echo "Der AP bootet nun und wird zur weiteren Konfiguration in Kürze "
echo "unter 192.168.1.1 erreichbar sein."
echo
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
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'dd if=/dev/zero bs=1 count=1 of=/dev/mtd4'
sshpass -p 'ubnt' ssh ubnt@192.168.1.20 'reboot'
echo
echo "Der AP bootet nun und wird zur weiteren Konfiguration in Kürze "
echo "unter 192.168.1.1 erreichbar sein."
echo
}

# main
clear
echo "Automatisiertes Firmware-Flashing für Ubiquiti AC Lite / AC Mesh Geräte"
echo "======================================================================="
echo
echo "Bitte diesen PC unter der IP-Adresse 192.168.1.20/24 erreichbar"
echo "machen und Ubiquiti Hardware mit dem Netzwerk verbinden."
echo
echo "Die zu flashende Firmware muss unter dem Dateinamen acmesh.bin/aclite.bin"
echo "im Verzeichnis dieses Scriptes liegen."
echo
echo
PS3='Bitte wählen: '
options=("Flashen AC Lite" "Flashen AC Mesh" "Beenden")
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
        "Beenden")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
