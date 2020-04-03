#!/bin/sh

threshhold_pct=50
nf_conntrack_max=16384

nf_conntrack_count=$(cat /proc/net/nf_conntrack | wc | awk '{print $1}')
nf_conntrack_dec=$(echo "scale=2 ; $nf_conntrack_count / $nf_conntrack_max" | bc)
nf_conntrack_pctdec=$(expr $nf_conntrack_dec*100 | bc)
nf_conntrack_pct=$(echo ${nf_conntrack_pctdec%.*})

if [ $nf_conntrack_pct -gt $threshhold_pct ]; then
	d=$(date)
        echo "To:email@example.com" > /etc/nf_conntrackmon/msgfinal.txt
        echo "From:email@example.com" >> /etc/nf_conntrackmon/msgfinal.txt
        echo "Subject:Cron Alert (server notification: nf_conntrack count $nf_conntrack_pct% too high) $d" >> /etc/nf_conntrackmon/msgfinal.txt
        echo "" >> /etc/nf_conntrackmon/msgfinal.txt
        uptime >> /etc/nf_conntrackmon/msgfinal.txt
        echo "" >> /etc/nf_conntrackmon/msgfinal.txt
	echo "Top 5 Users have highest established connection:" >> /etc/nf_conntrackmon/msgfinal.txt
        echo "NUMBER OF CONNECTIONS - IP ADDRESS" >> /etc/nf_conntrackmon/msgfinal.txt
        cat /proc/net/nf_conntrack | grep ESTABLISHED | awk '{print $7}' | cut -d= -f2 | sort | uniq -c | sort -nr | head -5 >> /etc/nf_conntrackmon/msgfinal.txt

        ssmtp email@example.com < /etc/nf_conntrackmon/msgfinal.txt
fi
