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
    -storepass changeit -importcert -noprompt -trustcacerts\
    -alias "$2"\
    -file "$3" 
}

#get cert store from phone
adb pull /system/etc/security/cacerts.bks

#do the work
count=${#CERT_FILES[@]}
for i in `seq 1 $count`;do
  add_cert "${FILE}" "${CERT_ALIAS[$i-1]}" "${CERT_FILES[$i-1]}"
done

#push cert store back to phone
adb shell busybox mount -o remount,rw /system
adb push cacerts.bks /system/etc/security
adb shell busybox mount -o remount,ro /system

#clean up
rm -rf $FILE
