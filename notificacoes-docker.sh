#!/bin/bash
# ESCRITO POR SANSÃO

CMDLINE=$0
USER_ROOT=$(id | cut -d= -f2 | cut -d\( -f1)

# Detecta se é um usuário com poderes de root que esta executando o script
#####################################################################################
if [ ! "$USER_ROOT" -eq 0 ] ; then
        echo ""
        echo "você deve ser root para executar este script, execute o comando:"
        echo ""
        echo "sudo bash $CMDLINE"
        echo ""
        exit 1
fi

sudo apt-get install -y dos2unix git sudo curl

PATHSOURCE="/etc/zabbix/scripts"
PATHSCRIPTS0="$(/usr/sbin/zabbix_server --help | grep "AlertScriptsPath" | awk '{ print $2 }' | tr -d "\"")" 2>/dev/null
PROJETO=Graphical_notifications_Zabbix
URLGIT=https://github.com/sansaoipb/$PROJETO


if [ -z $PATHSCRIPTS0 ]; then
  PATHSCRIPTS0=$PATHSOURCE
  PATHSCRIPTS=$PATHSCRIPTS0
  sudo mkdir -p $PATHSCRIPTS0

else
  PATHS=$PATHSCRIPTS0
  delete=alertscripts
  ARRAY=${PATHS[@]/$delete}
  PATHSCRIPTS=$ARRAY
  sudo mkdir -p $PATHSCRIPTS
  ln -s $PATHSCRIPTS0 $PATHSOURCE

fi

################################################ WppConnect ################################################
cd $PATHSCRIPTS0
git clone https://github.com/wppconnect-team/wppconnect-server.git
cd wppconnect-server
npm install
npm run build
sudo npm install -g pm2
sed -i "s/deviceName: 'WppConnect'/deviceName: 'SendGraph'/" $PATHSCRIPTS0/wppconnect-server/src/config.ts
################################################ WppConnect ################################################

cd /tmp/

if [ ! -e $PROJETO ] ; then
  git clone -b beta $URLGIT
fi

if [ ! -e "$PATHSCRIPTS0/configScripts.properties" ] ; then
  sudo cp -R /tmp/$PROJETO/configScripts.properties $PATHSCRIPTS0
fi

cd /tmp/$PROJETO/ ; sudo cp -R notificacoes* $PATHSCRIPTS0 ; cd $PATHSCRIPTS0 ; sudo chmod +x *.py ; dos2unix *.py ; sudo rm -rf /tmp/$PROJETO/

echo ""
echo "Execute o comando abaixo para editar o arquivo de configuração:"
echo ""
echo "cd $PATHSCRIPTS0 ; sudo -u zabbix vim configScripts.properties"
echo ""
echo "e vamos começar com os envios"
echo ""

sudo rm -rf /tmp/notificacoes.sh
