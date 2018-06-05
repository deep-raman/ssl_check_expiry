#!/bin/bash
TARGET="$1"
DAYS=15;
expirationdate=$(date -d "$(: | openssl s_client -connect $TARGET:443 -servername $TARGET 2>/dev/null \
                              | openssl x509 -text \
                              | grep 'Not After' \
                              |awk '{print $4,$5,$7}')" '+%s');
in7days=$(($(date +%s) + (86400*$DAYS)));
#expirationdate=$(($(date +%s) + (86400*5)))
if [ $in7days -gt $expirationdate ]; then
    echo "KO - Certificate for $TARGET expires in less than $DAYS days, on $(date -d @$expirationdate '+%Y-%m-%d')"
    exit 1
else
    echo "OK - Certificate expires on $(date -d @$expirationdate '+%Y-%m-%d')";
    exit 0
fi
