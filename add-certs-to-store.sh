#!/bin/bash
# A simple script to add certificates to the Android certificate store
# author: notizblock <nblock@archlinux.us>
# license: GPLv3

#add modify $CERT_FILES und $CERT_ALIAS to fit your needs
CERT_FILES=(certs/root.crt certs/class3.crt)
CERT_ALIAS=("CAcert Root" "CAcert Class 3")
FILE=cacerts.bks

#$1 -> absolute path to cacerts.bks
#$2 -> alias
#$3 -> certificate file
function add_cert {
  keytool -keystore "$1" -storetype BKS\
    -provider org.bouncycastle.jce.provider.BouncyCastleProvider\
    -storepass changeit -importcert -trustcacerts\
    -alias "$2"\
    -file "$3" 
}

#check args
if [ $# -ne 1 ]; then
  echo "Usage: `basename $0` /path/to/mounted/android-sdcard" && exit 1
fi

#check if cacerts.bks is writeable
ABS_FILE="$1/$FILE"
if [ ! -w "$ABS_FILE" ]; then
  echo "The file '${ABS_FILE} is not writeable. Please make sure that the file is writeable." && exit 1
fi

#do the work
count=${#CERT_FILES[@]}
for i in `seq 1 $count`;do
  add_cert "${ABS_FILE}" "${CERT_ALIAS[$i-1]}" "${CERT_FILES[$i-1]}"
done
