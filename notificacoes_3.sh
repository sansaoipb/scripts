#!/bin/bash
# ESCRITO POR SANSÃO

PATHSCRIPTS="/etc/zabbix/scripts"
PROJETO=Graphical_notifications_Zabbix
URLGIT=https://github.com/sansaoipb/$PROJETO

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
