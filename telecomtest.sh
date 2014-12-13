#!/bin/bash 

# Script for testing Atlant Telecom internet connection quality
# Initial adaptation for Linux by Denis Pynkin (dans@altlinux.org) (c) 2014

UTILITES="ping traceroute ip netstat"
PINGTRIES=${PINGTRIES:=50}

LOGDIR=${LOGDIR:=.}
PINGLOG=$LOGDIR/PING.txt
PATHLOG=$LOGDIR/PATHPING.txt
CONFLOG=$LOGDIR/CONFIG.txt

EXTRAPINGLOG=$LOGDIR/PING2.txt
EXTRAPING=${EXTRAPING:=no}

# Copy all output to console by default
VERBOSE=${VERBOSE:=yes}

# 1-st arg -- name of the file
logger() {
	LOG="$1"
	[ "$VERBOSE" == "yes" ] && tee -a "$LOG" || (cat >> "$LOG")
}

UPASS=0
# 0. Check availability
for util in $UTILITES ; do
	if ! which $util &>/dev/null; then
		 echo "Utilita $util ne naidena!!!"
		 UPASS=1
	fi
done

START="$(date +%Y-%m-%d-%T)"

# 1. Check access
# Check if utilities are usable by current user
if ! ping 127.0.0.1 -c 1 &>/dev/null ; then
	echo "Utilita PING ne rabotet! Poprobuite zapustit s pravami 'root'"
	UPASS=1
fi

if ! traceroute -n 127.0.0.1 &>/dev/null ; then
	echo "Utilita TRACEROUTE ne rabotet! Poprobuite zapustit s pravami 'root'"
	UPASS=1
fi

if [ $UPASS -gt 0 ]; then
	exit 1
fi
# check passed


# Clean logs
# may fail if permissions denied
set -e
for LOG in "$PINGLOG" "$PATHLOG" "$CONFLOG" "$EXTRAPINGLOG"; do
	[ -f "$LOG" ] && mv -f "$LOG" "$LOG".bak
	touch "$LOG"
done
set +e

echo TEST nachalsia! Dojdites ego vipolnenia! 

echo 0 TIME
# time /t >> C:\CONFIG.txt 2>&1
(LC_ALL=C date) 2>&1 | logger "$CONFLOG"

echo PING test. WAIT...
(
echo 1. PING 213.184.225.37  WAIT...
#ping 213.184.225.37 -n 50>>C:\PING.txt 2>&1
ping -c $PINGTRIES 213.184.225.37
echo 2. PING TUT.BY  WAIT...
#ping 178.124.133.65 -n 50>>C:\PING.txt 2>&1
ping -c $PINGTRIES 178.124.133.65
echo 3. PING GOOGLE DNS  WAIT...
#ping 8.8.8.8 -n 50>>C:\PING.txt 2>&1
ping -c $PINGTRIES 8.8.8.8 
)2>&1 | logger "$PINGLOG"

echo PATHPING test. WAIT...
(
echo 4. PATHPING TUT.BY WAIT...
#pathping 178.124.133.65>>C:\PATHPING.txt 2>&1
traceroute -n 178.124.133.65

echo 5. PATHPING GOOGLE DNS WAIT...
#pathping 8.8.8.8>>C:\PATHPING.txt 2>&1
traceroute -n 8.8.8.8
) 2>&1 | logger "$PATHLOG"

echo 6. IPCONFIG/ALL AND FLUSHDNS WAIT...
#ipconfig/all>>C:\CONFIG.txt 2>&1
#ipconfig /FLUSHDNS

# Do not need FLUSHDNS by default!
# Do not implement FLUSHDNS due a lot of different DNS resolvers 
# local and remote cache proxies configurations. 
# TODO: restart local dnsmasq?
(
echo "##### Interfaces #####"
ip link show
echo "##### IP addresses #####"
ip addr show
echo "##### Route table #####"
ip route show
echo 7. NSLOOKUP TELECOM.BY
#nslookup telecom.by >> C:\CONFIG.txt 2>&1
nslookup TELECOM.BY
echo 8. NETSTAT
#netstat -b >> C:\CONFIG.txt 2>&1
netstat -nptu 
) 2>&1 | logger "$CONFLOG"


# Check ping with different packet sizes and timing
# including size greather than MTU
(
if [ "$EXTRAPING" == "yes" ] ; then
	echo 9. EXTRA PING tests
	for PKTSIZE in 128 512 1024 4096 ; do
		for DELAY in 1 0.5 0.2 ; do
			for TARGET in "213.184.225.37" "178.124.133.65" "8.8.8.8" ; do
				echo "#### Ping $TARGET with packet size $PKTSIZE and delay $DELAY #####"
				ping -c $PINGTRIES -i $DELAY -s $PKTSIZE $TARGET
			done
		done
	done
fi
) 2>&1 | logger "$EXTRAPINGLOG"

ARCHIVELIST="$CONFLOG $PINGLOG $PATHLOG"
[ "$EXTRAPING" == "yes" ] && ARCHIVELIST="$ARCHIVELIST $EXTRAPINGLOG"
tar -czf "$LOGDIR"/telecomtest-$START.tar.gz $ARCHIVELIST

echo READY!!!
