#!/bin/bash

read -p "Enter the CIDR block for your LAN (0.0.0.0/0 notation): " cidrblockLAN
read -p "Enter the CIDR block for your VPC (0.0.0.0/0 notation): " cidrblockAWS


psk0=$(awk -v n=1 '/- Pre-Shared Key/ { if (++count == n) {print $NF}}' $1)
psk1=$(awk -v n=2 '/- Pre-Shared Key/ { if (++count == n) {print $NF}}' $1)

vgw0=$(awk -v n=1 '/- Virtual Private Gateway/ { if (++count == n) {print $NF}}' $1)
vgw1=$(awk -v n=3 '/- Virtual Private Gateway/ { if (++count == n) {print $NF}}' $1)

nbr0=$(awk -v n=2 '/- Virtual Private Gateway/ { if (++count == n) {print $NF}}' $1 | cut -d '/' -f 1)
nbr1=$(awk -v n=4 '/- Virtual Private Gateway/ { if (++count == n) {print $NF}}' $1 | cut -d '/' -f 1)


eth0=$(awk -v n=1 '/- Customer Gateway/ { if (++count == n) {print $NF}}' $1)
vti0=$(awk -v n=2 '/- Customer Gateway/ { if (++count == n) {print $NF}}' $1)
vti1=$(awk -v n=5 '/- Customer Gateway/ { if (++count == n) {print $NF}}' $1)

cgwASN=$(awk -v n=1 '/- Customer Gateway ASN/ { if (++count == n) {print $NF}}' $1)
vpgASN=$(awk -v n=1 '/- Virtual Private  Gateway ASN/ { if (++count == n) {print $NF}}' $1)


#
# echo "$psk0"
# echo "$psk1"
# echo "$vgw0"
# echo "$vgw1"
# echo "$eth0"
# echo "$vti0"
# echo "$vti1"
# echo "$cgwASN"
# echo "$vpgASN"
# echo "$nbr0"
# echo "$nbr1"

# pdJMbIjbbHALp7UTGyR_Br7Bieozi5l6
# d5nzbsq8Dv2p.S9Y_ZRShsCxwOz213J4
# 35.168.43.101
# 35.169.4.113
# 47.196.80.131
# 169.254.47.214/30
# 169.254.44.190/30
# 65009
# 7224
# 169.254.47.213
# 169.254.44.189

echo "configure"
echo "set vpn ipsec auto-firewall-nat-exclude enable"
echo "set vpn ipsec ike-group FOO0 key-exchange ikev1"
echo "set vpn ipsec ike-group FOO0 lifetime 28800"
echo "set vpn ipsec ike-group FOO0 proposal 1 dh-group 2"
echo "set vpn ipsec ike-group FOO0 proposal 1 encryption aes128"
echo "set vpn ipsec ike-group FOO0 proposal 1 hash sha1"
echo "set vpn ipsec ike-group FOO0 dead-peer-detection action restart"
echo "set vpn ipsec ike-group FOO0 dead-peer-detection interval 15"
echo "set vpn ipsec ike-group FOO0 dead-peer-detection timeout 30"
echo "set vpn ipsec esp-group FOO0 lifetime 3600"
echo "set vpn ipsec esp-group FOO0 pfs enable"
echo "set vpn ipsec esp-group FOO0 proposal 1 encryption aes128"
echo "set vpn ipsec esp-group FOO0 proposal 1 hash sha1"
echo "set vpn ipsec site-to-site peer $vgw0 authentication mode pre-shared-secret"
echo "set vpn ipsec site-to-site peer $vgw0 authentication pre-shared-secret $psk0"
echo "set vpn ipsec site-to-site peer $vgw0 connection-type initiate"
echo "set vpn ipsec site-to-site peer $vgw0 description ipsec-aws"
echo "set vpn ipsec site-to-site peer $vgw0 local-address $eth0"
echo "set vpn ipsec site-to-site peer $vgw0 ike-group FOO0"
echo "set vpn ipsec site-to-site peer $vgw0 vti bind vti0"
echo "set vpn ipsec site-to-site peer $vgw0 vti esp-group FOO0"
echo "set vpn ipsec site-to-site peer $vgw1 authentication mode pre-shared-secret"
echo "set vpn ipsec site-to-site peer $vgw1 authentication pre-shared-secret $psk1"
echo "set vpn ipsec site-to-site peer $vgw1 connection-type initiate"
echo "set vpn ipsec site-to-site peer $vgw1 description ipsec-aws"
echo "set vpn ipsec site-to-site peer $vgw1 local-address $eth0"
echo "set vpn ipsec site-to-site peer $vgw1 ike-group FOO0"
echo "set vpn ipsec site-to-site peer $vgw1 vti bind vti1"
echo "set vpn ipsec site-to-site peer $vgw1 vti esp-group FOO0"
echo "set interfaces vti vti0 address $vti0"
echo "set interfaces vti vti1 address $vti1"
echo "set firewall options mss-clamp interface-type vti"
echo "set firewall options mss-clamp mss 1379"
echo "set policy prefix-list BGP rule 10 action deny"
echo "set policy prefix-list BGP rule 10 description 'deny local wan'"
echo "set policy prefix-list BGP rule 10 prefix $eth0/32"
echo "set policy prefix-list BGP rule 20 action deny"
echo "set policy prefix-list BGP rule 20 description 'deny aws vgw1'"
echo "set policy prefix-list BGP rule 20 prefix $vgw0/32"
echo "set policy prefix-list BGP rule 30 action deny"
echo "set policy prefix-list BGP rule 30 description 'deny aws vgw2'"
echo "set policy prefix-list BGP rule 30 prefix $vgw1/32"
echo "set policy prefix-list BGP rule 100 action permit"
echo "set policy prefix-list BGP rule 100 description 'permit local lan'"
echo "set policy prefix-list BGP rule 100 prefix $cidrblockLAN"
echo "set policy prefix-list BGP rule 110 action permit"
echo "set policy prefix-list BGP rule 110 description 'permit aws vpc'"
echo "set policy prefix-list BGP rule 110 prefix $cidrblockAWS"
echo "set protocols bgp $cgwASN timers holdtime 30"
echo "set protocols bgp $cgwASN timers keepalive 10"
echo "set protocols bgp $cgwASN network $cidrblockLAN"
echo "set protocols bgp $cgwASN neighbor $nbr0 prefix-list export BGP"
echo "set protocols bgp $cgwASN neighbor $nbr0 prefix-list import BGP"
echo "set protocols bgp $cgwASN neighbor $nbr0 remote-as $vpgASN"
echo "set protocols bgp $cgwASN neighbor $nbr0 soft-reconfiguration inbound"
echo "set protocols bgp $cgwASN neighbor $nbr1 prefix-list export BGP"
echo "set protocols bgp $cgwASN neighbor $nbr1 prefix-list import BGP"
echo "set protocols bgp $cgwASN neighbor $nbr1 remote-as $vpgASN"
echo "set protocols bgp $cgwASN neighbor $nbr1 soft-reconfiguration inbound"
echo "set protocols bgp $cgwASN network $cidrblockLAN"
echo "commit"
