#!/bin/bash

##########################################################################################################
#
#  Script to check ssl certificate expiry date.
#
#  Author        :  Raman Deep
#  Email         :  raman@sky-tours.com
#  Date          :  05-06-2018
#  Version       :  2.0
#
##########################################################################################################

usage()
{
cat <<EOF
Usage: $(basename $0) [options]
 
This shell script is a simple wrapper around the openssl binary. It uses
s_client to get certificate information from remote hosts, or x509 for local
certificate files. It can parse out some of the openssl output or just dump all
of it as text.
 
Options:
 
  --file       Use a local certificate file for input.

  --host       Fetch the certificate from this remote host.
 
  --help       Print this help message.

Examples:

	1. Check remote host certificate expiry date :

		$(basename $0) --host sky-tours.com

	2. Check expiry date from local certificate file :

		$(basename $0) --file /etc/ssl/example.crt

EOF
}
 
DAYS=15;

in7days=$(($(date +%s) + (86400*$DAYS)));

if ! [ -x "$(type -P openssl)" ]; then
	echo "ERROR: script requires openssl"
	echo "For Debian and friends, get it with 'apt-get install openssl'"
	exit 1
fi

while [ "$1" ]; do
	case "$1" in
        --file)
            shift
            TARGET="$1"
            source="local"
            ;;
        --host)
            shift
            TARGET="$1"
            source="remote"
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "$(basename $0): invalid option $1" >&2
            echo "see --help for usage"
            exit 1
            ;;
  	esac
  	shift
done

CheckLocalCert() {
	expirationdate=$(date -d "$(: | openssl x509 -in $TARGET -text -noout | grep 'Not After' | awk '{print $4,$5,$7}')" '+%s');
}

CheckRemoteCert() {
	expirationdate=$(date -d "$(: | openssl s_client -connect $TARGET:443 -servername $TARGET 2>/dev/null \
                            	  | openssl x509 -text \
                                  | grep 'Not After' \
                                  | awk '{print $4,$5,$7}')" '+%s');
}

if [ -z "$source" ]; then
	echo "ERROR: missing certificate source."
	echo "Provide one via '--file' or '--host' arguments."
	echo "See '--help' for examples." 
  	exit 1
fi

if [ "$source" == "local" ]; then
	if [ -z "$TARGET" ]; then
		echo "ERROR: missing certificate file"
    	exit 1
  	fi
  	CheckLocalCert
fi

if [ "$source" == "remote" ]; then
	if [ -z "$TARGET" ]; then
		echo "ERROR: missing remote host value."
		echo "Provide one via '--host' argument"
		exit 1
	fi
	CheckRemoteCert
fi

if [ -z "$expirationdate" ]; then
	echo "ERROR: Unable to get certificate expiry date"
	exit 1
fi

if [ $in7days -gt $expirationdate ]; then
    echo "KO - Certificate for $TARGET expires in less than $DAYS days, on $(date -d @$expirationdate '+%Y-%m-%d')"
    exit 1
else
    echo "OK - Certificate expires on $(date -d @$expirationdate '+%Y-%m-%d')";
    exit 0
fi;