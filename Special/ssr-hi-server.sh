#!/bin/sh
if [ `id -u` -ne 0 ] 
then
  echo "Need root, try with sudo"
  exit 0
fi

echo ""
echo "一键SSR-server高级版"
echo ""

apt-get -y install python-pip
apt-get -y install m2crypto git

apt-get install build-essential
wget https://github.com/jedisct1/libsodium/releases/download/1.0.8/libsodium-1.0.8.tar.gz
tar xf libsodium-1.0.8.tar.gz && cd libsodium-1.0.8
./configure && make -j2 && make install
ldconfig

cd ~
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


cd /etc
wget https://raw.githubusercontent.com/mountainguan/ShadowsocksR-OneClick/master/shadowsocks.json

cd ~/shadowsocks/shadowsocks

python server.py -c /etc/shadowsocks.json -d start

iptables -I INPUT -p tcp -m tcp --dport 2333 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 4666 -j ACCEPT
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
echo "Port: 4666"
echo "Password: mountainguan"
echo "Method: chacha20"
echo "Local_port: 1080"
echo "===================================================================="
exit 0
