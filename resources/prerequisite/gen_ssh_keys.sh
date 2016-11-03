#!/bin/bash
#
# This helper script is extracted from '/etc/init.d/sshd'
#

# source function library
. /etc/rc.d/init.d/functions

KEYGEN=/usr/bin/ssh-keygen
RSA1_KEY=/etc/ssh/ssh_host_key
RSA_KEY=/etc/ssh/ssh_host_rsa_key
DSA_KEY=/etc/ssh/ssh_host_dsa_key

fips_enabled() {
	if [ -r /proc/sys/crypto/fips_enabled ]; then
		cat /proc/sys/crypto/fips_enabled
	else
		echo 0
	fi
}

do_rsa1_keygen() {
	if [ ! -s $RSA1_KEY -a `fips_enabled` -eq 0 ]; then
		echo -n $"Generating SSH1 RSA host key: "
		rm -f $RSA1_KEY
		if test ! -f $RSA1_KEY && $KEYGEN -q -t rsa1 -f $RSA1_KEY -C '' -N '' >&/dev/null; then
			chmod 600 $RSA1_KEY
			chmod 644 $RSA1_KEY.pub
			if [ -x /sbin/restorecon ]; then
			    /sbin/restorecon $RSA1_KEY.pub
			fi
			success $"RSA1 key generation"
			echo
		else
			failure $"RSA1 key generation"
			echo
			exit 1
		fi
	fi
}

do_rsa_keygen() {
	if [ ! -s $RSA_KEY ]; then
		echo -n $"Generating SSH2 RSA host key: "
		rm -f $RSA_KEY
		if test ! -f $RSA_KEY && $KEYGEN -q -t rsa -f $RSA_KEY -C '' -N '' >&/dev/null; then
			chmod 600 $RSA_KEY
			chmod 644 $RSA_KEY.pub
			if [ -x /sbin/restorecon ]; then
			    /sbin/restorecon $RSA_KEY.pub
			fi
			success $"RSA key generation"
			echo
		else
			failure $"RSA key generation"
			echo
			exit 1
		fi
	fi
}

do_dsa_keygen() {
	if [ ! -s $DSA_KEY -a `fips_enabled` -eq 0 ]; then
		echo -n $"Generating SSH2 DSA host key: "
		rm -f $DSA_KEY
		if test ! -f $DSA_KEY && $KEYGEN -q -t dsa -f $DSA_KEY -C '' -N '' >&/dev/null; then
			chmod 600 $DSA_KEY
			chmod 644 $DSA_KEY.pub
			if [ -x /sbin/restorecon ]; then
			    /sbin/restorecon $DSA_KEY.pub
			fi
			success $"DSA key generation"
			echo
		else
			failure $"DSA key generation"
			echo
			exit 1
		fi
	fi
}

do_rsa_keygen
do_rsa1_keygen
do_dsa_keygen
