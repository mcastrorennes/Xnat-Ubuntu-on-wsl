reset
echo
echo
echo ---------------------------------------
echo Installation of XNAT for WSL Ubuntu 22.04 
echo ---------------------------------------
echo
echo This script installs:
echo
echo '-----> NAT version to 1.8.9.1'
echo '-----> Tomcat Websever'
echo '-----> Plugins & Pipelines'
echo '-----> Testdata and Skripts'
echo '-----> Pipeline Engine'
echo '-----> XNAT Container Service'
echo '-----> nrgix Proxy'
echo '-----> Xnat-Ubuntu'
echo '-----> Docker'
echo
echo Please check:
echo 1. you run this script on WSL Ubuntu 22.04 
echo 2. you have internet
echo 3. you have sudo privileges
echo
echo 'Start installation?'
select yn in 'Yes' 'No'; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done
echo
echo Setting network connections under WSL
# avoid somes problems with wget
echo ---------------------------------------
sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "[network]" > /etc/wsl.conf'
sudo bash -c 'echo "generateResolvConf = false" >> /etc/wsl.conf'
sudo chattr +i /etc/resolv.conf
echo
echo install System!
echo ---------------------------------------
cd /
sleep 2
echo
echo Update System
echo ---------------------------------------
sleep 2
#apt-get install sudo
sudo apt-get update
sudo apt-get upgrade
echo
echo install basic dependencies
echo ---------------------------------------
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
echo
# echo Install Docker
# vurl -fsSL https://get.docker.com | sh
# echo ---------------------------------------
# sleep 2
# sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo apt-get install curl
# sudo curl -L "https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
echo
echo Install XNAT
echo ---------------------------------------
sleep 2
mkdir -p /data/xnat/archive
mkdir -p /data/xnat/build
mkdir -p /data/xnat/home
mkdir -p /data/xnat/cache
mkdir -p /data/xnat/home/plugins
mkdir -p /data/xnat/home/logs

cd /
sudo git clone https://github.com/mcastrorennes/Xnat-Ubuntu-on-wsl.git
#cp default.env .env
cd Xnat-Ubuntu-on-wsl
sudo docker-compose up -d
chmod +x RESTApiTest/APItest.sh
chmod +x RESTApiTest/APItest_multifiles.sh

#workaround if processing url is not found
#apt-get install iptables
#iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 127.0.0.1:8081
#iptables -P INPUT ACCEPT
#iptables -P OUTPUT ACCEPT
#iptables -P FORWARD ACCEPT
