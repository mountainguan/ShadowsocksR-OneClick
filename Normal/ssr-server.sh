#!/bin/sh
if [ `id -u` -ne 0 ] 
then
  echo "Need root, try with sudo"
  exit 0
fi

echo ""
echo "Welcome to use SSR-server one click install script"
echo "Made by WangTongze WEBSITE: wangtongze.tk"
echo ""

apt-get update
apt-get -y install python-pip
apt-get -y install m2crypto git


git clone -b manyuser https://github.com/breakwa11/shadowsocks.git


IP=`wget -q -O - http://api.ipify.org`

if [ "x$IP" = "x" ]
then
  echo "============================================================"
  echo "  !!!  COULD NOT DETECT SERVER EXTERNAL IP ADDRESS  !!!"
  echo "============================================================"
else
  echo "============================================================"
  echo "Detected your server external ip address: $IP"
  echo "============================================================"
fi

dir=`pwd`
ss="/shadowsocks"
cd $dir$ss

cat > config.json << END
{
    "server":"$IP",
    "server_ipv6": "::",
    "server_port":2333,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"mountainguan",
    "timeout":600,
    "method":"aes-256-cfb",
    "fast_open": false,
    "workers": 1
}
END
cd $dir$ss$ss
chmod +x *.sh
./run.sh
cd $dir
iptables -I INPUT -p tcp -m tcp --dport 2333 -j ACCEPT
iptables-save
head="ss://"
A="aes-256-cfb:mountainguan@"
B=":2333"

STR=`echo $A$IP$B | base64`
string=`echo ${STR/Cg==/}`
#generate the QR code
web="https://api.qrserver.com/v1/create-qr-code/?size=300x300&data="$head$string
echo "===================================================================="
echo "Get your server QR code on:"
echo $web
echo "===================================================================="
echo "Shadowsocks-RSS server info"
echo "Server ip: $IP"
echo "Port: 2333"
echo "Password: mountainguan"
echo "Method: aes-256-cfb"
echo "Local_port: 1080"
echo "===================================================================="
echo "If you want to get the lastest client of Shadowsocks-RSS"
echo "please go to wangtongze.tk"
echo "===================================================================="
exit 0
