#!/bin/bash
# ESCRITO POR SANSÃO

PROJETO=Graphical_notifications_Zabbix
URLGIT=https://github.com/sansaoipb/$PROJETO
PATHSCRIPTS0="/etc/zabbix/scripts"

############################################### WppConnect #############################################################
# Atualizando o sistema e instalando dependências
sudo apt update
sudo apt upgrade -y
sudo apt install -y npm curl dirmngr apt-transport-https lsb-release ca-certificates wget net-tools nginx
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
sudo apt install -y libgbm-dev unzip fontconfig locales gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils libxss-dev libappindicator1 libu2f-udev


# Instalando o Chrome
wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y
sudo apt update 

# Instalando e iniciando o WPP Connect
cd ~
git clone https://github.com/wppconnect-team/wppconnect-server.git
cd wppconnect-server
npm install
npm run build
sudo npm install -g pm2
pm2 start npm --name wpp -- start


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

sed -i "s/deviceName: 'WppConnect'/deviceName: 'SendGraph'/" /root/wppconnect-server/src/config.ts

sudo tee /usr/local/bin/wpp_connect > /dev/null <<EOF
sudo su -
cd /root/wppconnect-server
sudo pm2 status
pm2 start npm --name wpp -- start
EOF

sudo chmod +x /usr/local/bin/wpp_connect

sudo tee /etc/systemd/system/wppconnect.service  > /dev/null <<EOF
[Unit]
Description=Serviço de Envio para WhatsApp
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/wpp_connect
Restart=on-failure
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable wppconnect

############################################### WppConnect #############################################################

mkdir -p $PATHSCRIPTS0

apt-get install -y python3 python3-pip wget dos2unix git sudo curl bc vim; apt clean

pythonVersion=$(/usr/bin/python3 -V 2>&1 | cut -d' ' -f2 | cut -d. -f1,2)
rm -rf /usr/lib/python$pythonVersion/EXTERNALLY-MANAGED
cd /tmp/ ; sudo /usr/bin/pip3 install wheel requests urllib3 pyrogram tgcrypto pycryptodome flask

git clone -b beta $URLGIT

if [ -z "$PROJETO" ] ; then
  echo "Script não mexecutado, analise para resolver."
  exit 1
fi

sleep 5

if [ ! -e "$PATHSCRIPTS0/configScripts.properties" ] ; then
   sudo cp -R /tmp/$PROJETO/configScripts.properties $PATHSCRIPTS0
fi

cd /tmp/$PROJETO/
sudo cp -R notificacoes* $PATHSCRIPTS0
cd $PATHSCRIPTS0
sudo chmod +x *.py
dos2unix *.py
sudo rm -rf /tmp/$PROJETO/

echo ""
echo "Execute o comando abaixo para editar o arquivo de configuração:"
echo ""
echo "cd $PATHSCRIPTS0 ; sudo -u zabbix vim configScripts.properties"
echo ""
echo "e vamos começar com os envios"
echo ""
