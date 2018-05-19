# EdgeRouter-AWS-VPN-Dynamic-Config
Converts a generic AWS VPN config to a set of commands to execute on an Ubiquiti EdgeRouter

Please note that this script is for configuring **dynamic** routes with BGP, and is based on the oficial Ubiquiti guide: [EdgeRouter - IPsec Route-Based Site-to-Site VPN to AWS VPC (BGP over IKEv1/IPsec)](https://help.ubnt.com/hc/en-us/articles/115016128008)

Download the *vpn-xxxxxxxx.txt* file after configuring your VPN connection in your AWS console. Pass the file path as the first argument to this script. The script will then prompt you for the CIDR block of your LAN and VPC. There is currently no input validation on these fields so please make sure you enter them correctly!

The script will then return a set of commands which can be passed to your EdgeRouter CLI. 
