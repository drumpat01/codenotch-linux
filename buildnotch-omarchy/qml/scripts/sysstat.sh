#!/bin/sh
# One-shot system readout for the top bar; parsed by Lib.parseSys.
head -n 1 /proc/stat
awk '/^MemTotal:/{print "memtotal", $2} /^MemAvailable:/{print "memavail", $2}' /proc/meminfo
awk 'NR>2 && $1 !~ /^lo:/ {rx+=$2; tx+=$10} END {print "net", rx+0, tx+0}' /proc/net/dev
for b in /sys/class/power_supply/BAT*; do
    [ -r "$b/capacity" ] || continue
    echo "bat $(cat "$b/capacity") $(cat "$b/status" 2>/dev/null || echo Unknown)"
    break
done
