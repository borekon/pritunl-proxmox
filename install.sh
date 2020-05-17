apt-get update && apt-get upgrade -y

tee -a /etc/apt/sources.list.d/pritunl.list << EOF
deb http://repo.pritunl.com/stable/apt stretch main
EOF

sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list << EOF
deb https://repo.mongodb.org/apt/debian stretch/mongodb-org/4.2 main
EOF

echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' > /etc/apt/preferences.d/limit-unstable

apt install -y dirmngr
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv E162F504A20CDF15827F718D4B7C549A058F8B6B
apt-get update
apt install -y pritunl mongodb-server
systemctl start mongodb pritunl
systemctl enable mongodb pritunl
echo 'Installing wireguard...'
apt install -y wireguard-dkms wireguard-tools

sh -c 'echo "* hard nofile 64000" >> /etc/security/limits.conf'
sh -c 'echo "* soft nofile 64000" >> /etc/security/limits.conf'
sh -c 'echo "root hard nofile 64000" >> /etc/security/limits.conf'
sh -c 'echo "root soft nofile 64000" >> /etc/security/limits.conf'

cd /dev
mkdir net
cd net
mknod tun c 10 200
chmod 666 tun

echo 'Setup key:'
echo ''
pritunl setup-key
echo 'enter the key above and wait to the next step'
pause
echo 'First-time key:'
echo ''
pritunl default-password
