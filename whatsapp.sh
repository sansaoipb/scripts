#!/bin/bash

# Atualizando o sistema e instalando dependências
sudo apt update
sudo apt install -y vim git curl dirmngr apt-transport-https lsb-release ca-certificates wget net-tools
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install nodejs -y
sudo apt install -y libgbm-dev unzip fontconfig locales libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libnss3 lsb-release xdg-utils libxss-dev libappindicator1 libu2f-udev

# Instalando o Chrome
wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb ; rm -rf google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y

cd ~
if [ ! -e "~/wppconnect-server" ] ; then
  git clone https://github.com/wppconnect-team/wppconnect-server.git
fi

cd wppconnect-server
sed -i "s/deviceName: 'WppConnect'/deviceName: 'SendGraph'/" ~/wppconnect-server/src/config.ts
npm install
npm run build
sudo npm install -g pm2
  
# Abrindo portas no Firewall Ubuntu
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo service ufw restart
