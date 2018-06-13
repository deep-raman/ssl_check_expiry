# ssl_check_expiry


This shell script is a simple wrapper around the openssl binary. It uses s_client to get certificate information from remote hosts, or x509 for local
certificate files. It can parse out some of the openssl output or just dump all of it as text.
 
Options:
========
 	
 	--file       Use a local certificate file for input.
  	--host       Fetch the certificate from this remote host.
  	--help       Print help message.

Examples:
========

        1. Check remote host certificate expiry date :

			./check_certs.sh --host sky-tours.com

        2. Check expiry date from local certificate file :

            ./check_certs.sh --file /etc/ssl/example.crt
