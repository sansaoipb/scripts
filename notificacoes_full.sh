#!/bin/bash
# ESCRITO POR SANSÃO

PATHSCRIPTS="/etc/zabbix/scripts"
PROJETO=Graphical_notifications_Zabbix
URLGIT=https://github.com/sansaoipb/$PROJETO

############################################### WppConnect #############################################################
# Atualizando o sistema e instalando dependências
sudo apt update
sudo apt install -y vim git curl dirmngr apt-transport-https lsb-release ca-certificates wget net-tools nginx
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install nodejs -y
sudo apt install -y libgbm-dev unzip fontconfig locales libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libnss3 lsb-release xdg-utils libxss-dev libappindicator1 libu2f-udev

sudo mkdir -p $PATHSCRIPTS

# Instalando o Chrome
wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb ; rm -rf google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y

cd ~
if [ ! -e "~/wppconnect-server" ] ; then
  git clone https://github.com/wppconnect-team/wppconnect-server.git
  cd wppconnect-server
  sed -i "s/deviceName: 'WppConnect'/deviceName: 'SendGraph'/" ~/wppconnect-server/src/config.ts
  npm install
  npm run build
  sudo npm install -g pm2
fi

# Configurando o NGINX
sudo rm /etc/nginx/sites-enabled/default
sudo tee /etc/nginx/sites-available/wpp > /dev/null <<EOF
server {
  server_name api.seudominioaqui.com.br;
  location / {
     proxy_pass http://127.0.0.1:21465;
     proxy_http_version 1.1;
     proxy_set_header Upgrade \$http_upgrade;
     proxy_set_header Connection 'upgrade';
     proxy_set_header Host \$host;
     proxy_set_header X-Real-IP \$remote_addr;
     proxy_set_header X-Forwarded-Proto \$scheme;
     proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
     proxy_cache_bypass \$http_upgrade;
  }
}
EOF

sudo ln -s /etc/nginx/sites-available/wpp /etc/nginx/sites-enabled
sudo nginx -t
sudo service nginx restart

# Abrindo portas no Firewall Ubuntu
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo service ufw restart

############################################### WppConnect #############################################################

apt-get install -y python3 python3-pip wget dos2unix git sudo curl vim
sudo DEBIAN_FRONTEND=noninteractive apt install -y tzdata ; apt clean
rm /etc/localtime ; ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

pythonVersion=$(/usr/bin/python3 -V 2>&1 | cut -d' ' -f2 | cut -d. -f1,2)
rm -rf /usr/lib/python$pythonVersion/EXTERNALLY-MANAGED
cd /tmp/ ; sudo /usr/bin/pip3 install wheel requests urllib3 pyrogram tgcrypto pycryptodome flask

if [ ! -e $PROJETO ] ; then
  git clone -b beta $URLGIT
fi

if [ ! -e "$PATHSCRIPTS/configScripts.properties" ] ; then
  sudo cp -R /tmp/$PROJETO/configScripts.properties $PATHSCRIPTS
fi

sudo cp -R /tmp/$PROJETO/notificacoes* $PATHSCRIPTS ; sudo chmod +x $PATHSCRIPTS/*.py ; dos2unix $PATHSCRIPTS/*.py ; sudo rm -rf /tmp/$PROJETO

echo ""
echo "Execute o comando abaixo para editar o arquivo de configuração:"
echo ""
echo "cd $PATHSCRIPTS ; sudo -u zabbix vim configScripts.properties"
echo ""
echo "e vamos começar com os envios"
echo ""

sudo rm -rf /tmp/notificacoes.sh
