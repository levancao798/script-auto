#!bin/bash
KEY_DIR=/home/ubuntu/client-configs/keys
OUTPUT_DIR=/home/ubuntu/client-configs/files
BASE_CONFIG=/home/ubuntu/client-configs/base.conf

source /home/ubuntu/EasyRSA-3.0.4/vars
echo USERNAME:
read varname
echo IP:
read varip
echo GATEWAY:
read vargw

cd /home/ubuntu/EasyRSA-3.0.4/
./easyrsa build-client-full $varname
cp /home/ubuntu/EasyRSA-3.0.4/pki/private/$varname.key /home/ubuntu/client-configs/keys/ && cp /home/ubuntu/EasyRSA-3.0.4/pki/issued/$varname.crt /home/ubuntu/client-configs/keys/

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/$varname.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/$varname.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/$varname.ovpn

echo ifconfig-push $varip $vargw > /etc/openvpn/ccd/$varname-eway-office
echo -A FORWARD -s $varip/32 -m comment --comment "$varname" -j ACCEPT  iptables-rule >> /root/iptables-rule
iptables-restore < /root/iptables-rule
