#!/bin/bash
# ESCRITO POR SANSAO

# Detecta se eh um usuario com poderes de root que esta executando o script
#####################################################################################
CMDLINE=$0
USER_ROOT=$(id | cut -d= -f2 | cut -d\( -f1)
if [ ! "$USER_ROOT" -eq 0 ] ; then
        echo "voce deve ser root para executar este script."
        echo "execute o comando \"sudo $CMDLINE\""
        exit 1
fi
#####################################################################################

SCRIPTS=/usr/lib/zabbix/alertscripts/
DISTRO=/etc/redhat-release
PROJETO=Graphical_notifications_Zabbix
URLGIT=https://github.com/sansaoipb/$PROJETO
MODULOS=/var/lib/zabbix/

if [ ! -e $MODULOS ]
then
  cd /tmp/ ; sudo mkdir /var/lib/zabbix/ ; sudo chown -R zabbix. /var/lib/zabbix ; sudo -u zabbix python3 -m pip install requests urllib3 pyrogram tgcrypto --user
else
  cd /tmp/ ; sudo chown -R zabbix. /var/lib/zabbix ; sudo -u zabbix python3 -m pip install requests urllib3 pyrogram tgcrypto --user
fi


if [ ! -e $PROJETO ]
then
  git clone $URLGIT
fi

cd $PROJETO

if [ -e $SCRIPTS ]
then
  PATHSCRIPTS=/usr/lib/zabbix/alertscripts
else
  PATHSCRIPTS=/usr/local/share/zabbix/alertscripts
fi

cd $PATHSCRIPTS

if [ ! -e "configScripts.properties" ]
then
  cd /tmp/$PROJETO/ ; sudo cp -R notificacoes* configScripts.properties $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x $PATHSCRIPTS/*.py ; cd .. ; sudo chown -R zabbix. *

else
  cd /tmp/$PROJETO/ ; sudo cp -R notificacoes* $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x $PATHSCRIPTS/*.py ; cd .. ; sudo chown -R zabbix. *
fi

sudo rm -rf /tmp/$PROJETO/

clear

echo ""
echo "Entre em 'cd $PATHSCRIPTS/', edite o arquivo 'configScripts.properties' e depois execute o comando:"
echo ""
echo "sudo -u zabbix ./notificacoes-teste.py info"
echo ""
echo "para começar a configuração"
echo ""