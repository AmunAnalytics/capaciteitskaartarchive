#!/usr/bin/env bash

if [[ ! -e last_updated.txt ]]; then
	touch last_updated.txt
fi

curl -s https://capaciteitskaart.netbeheernederland.nl/ | grep Bijgewerkt | grep -E -o '[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}' > /tmp/netbeheerkaart_last_updated.txt
site_online=$?

if [[ $site_online == 0 ]]; then
	timestamp_diff="$(diff /tmp/netbeheerkaart_last_updated.txt last_updated.txt)"

	if [[ "0" != "${#timestamp_diff}" ]]; then
		curl -s https://capaciteitskaart.netbeheernederland.nl/dashboard/download > latest.csv
		mv /tmp/netbeheerkaart_last_updated.txt last_updated.txt
		timestamp="$(cat last_updated.txt)"
		cp latest.csv archive/"${timestamp// /_}".csv

		git add *.csv
		git add archive/*.csv
		git commit -m "beep boop automated update" --author="Amun Analytics Bot <frank@amunanalytics.eu>"
		git push
	fi
fi
