#!/bin/bash
IP_TMP=/tmp/ip.tmp
IP_BLACKLIST=/etc/ip-blacklist.conf
IP_BLACKLIST_TMP=/tmp/ip-blacklist.tmp
IP_BLACKLIST_CUSTOM=/etc/ip-blacklist-custom.conf # optional
BLACKLISTS=(
"http://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1" # Project Honey Pot Directory of Dictionary Attacker IPs
"http://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.1.1.1"  # TOR Exit Nodes
"http://www.maxmind.com/en/anonymous_proxies" # MaxMind GeoIP Anonymous Proxies
"http://danger.rulez.sk/projects/bruteforceblocker/blist.php" # BruteForceBlocker IP List
"http://rules.emergingthreats.net/blockrules/rbn-ips.txt" # Emerging Threats - Russian Business Networks List
"http://www.spamhaus.org/drop/drop.lasso" # Spamhaus Don't Route Or Peer List (DROP)
"http://cinsscore.com/list/ci-badguys.txt" # C.I. Army Malicious IP List
"http://www.openbl.org/lists/base.txt"  # OpenBL.org 30 day List
"http://www.autoshun.org/files/shunlist.csv" # Autoshun Shun List
)
for i in "${BLACKLISTS[@]}"
do
    curl "$i" > $IP_TMP
    grep -Po '(?:\d{1,3}\.){3}\d{1,3}(?:/\d{1,2})?' $IP_TMP >> $IP_BLACKLIST_TMP
done
sort $IP_BLACKLIST_TMP -n | uniq > $IP_BLACKLIST
rm $IP_BLACKLIST_TMP
wc -l $IP_BLACKLIST

ipset flush blacklist
egrep -v "^#|^$" $IP_BLACKLIST | while IFS= read -r ip
do
        ipset add blacklist $ip
done

if [ -f $IP_BLACKLIST_CUSTOM ]; then
        egrep -v "^#|^$" $IP_BLACKLIST_CUSTOM | while IFS= read -r ip
        do
                ipset add blacklist $ip
        done
fi
