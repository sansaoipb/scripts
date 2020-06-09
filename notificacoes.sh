#!/bin/bash
# ESCRITO POR SANSAO

SCRIPTS=/usr/lib/zabbix/alertscripts/
DISTRO=/etc/redhat-release
PROJETO=Graphical_notifications_Zabbix
URLGIT=https://github.com/sansaoipb/$PROJETO

if [ ! -e $PROJETO ]
then
  git clone $URLGIT
fi

cd $PROJETO ; sudo unzip telegram.zip ; sudo rm -rf README.md ; sudo rm -rf telegram.zip ; cd telegram ; sudo chmod +x telegram-cli* ; cd /tmp/

if [ -e $DISTRO ]
then
  cd $PROJETO/telegram ; sudo mv telegram-cli.CentOS telegram-cli ; sudo yum install -y jansson-devel openssl098e.x86_64 python34-libs libconfig-devel readline-devel libevent-devel lua-devel python-devel python3-devel python-pip python3-pip python-requests python3-requests ; sudo ln -s /usr/lib64/liblua-5.1.so /usr/lib64/liblua5.2.so.0 ; sudo ln -s /usr/lib64/libcrypto.so.0.9.8e /usr/lib64/libcrypto.so.1.0.0
else
  cd $PROJETO/telegram ; sudo rm -rf telegram-cli.CentOS ; sudo apt-get install -y libjansson-dev libreadline-dev libconfig-dev libssl-dev libevent-dev libjansson-dev libpython-dev libpython3-all-dev liblua5.2-0 python-pip python3-pip python-requests python3-requests
fi

if [ -e $SCRIPTS ]
then
  PATHSCRIPTS=/usr/lib/zabbix/alertscripts
else
  PATHSCRIPTS=/usr/local/share/zabbix/alertscripts
fi

cd $PATHSCRIPTS

if [ ! -e "configScrips.properties" ]
then
  cd /tmp/$PROJETO/ ; sudo cp -R telegram* notificacoes* configScrips.properties $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x $PATHSCRIPTS/*.py ; cd .. ; sudo chown -R zabbix. *

else
  cd /tmp/$PROJETO/ ; sudo cp -R telegram* notificacoes* $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x $PATHSCRIPTS/*.py ; cd .. ; sudo chown -R zabbix. *

fi

sed -i "s,/etc/zabbix/scripts,$PATHSCRIPTS,g" $PATHSCRIPTS/telegram/telegram.config

sudo rm -rf /tmp/$PROJETO/

clear

echo ""
echo "Execute"
echo ""
echo "cd '$PATHSCRIPTS'/telegram ; sudo -u zabbix ./telegram-cli --rsa-key tg-server.pub --config telegram.config"
echo ""
echo "para começar a configuração"
echo ""
