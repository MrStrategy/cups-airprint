#!/bin/bash
inotifywait -m -e close_write,moved_to,create /etc/cups | 
while read -r directory events filename; do
	if [ "$filename" = "printers.conf" ]; then
		rm -rf /services/AirPrint-*.service
		/root/airprint-generate.py -d /services
		cp /etc/cups/printers.conf /config/printers.conf
                rm -rf /etc/avahi/services/*
                if [ `ls -l /services/*.service 2>/dev/null | wc -l` -gt 0 ]; then
                    cp -f /services/*.service /etc/avahi/services/
                fi
	fi
done
