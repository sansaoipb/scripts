#!/bin/bash
# ESCRITO POR SANSAO

#if [ `whoami` != "zabbix" ] ; then
#        echo ""
#        echo "voce deve estar logado com o user zabbix para continuar."
#        echo "Se nunca logou com ele, execute o comando em seguida logue"
#        echo ""
#        echo "sudo usermod -s /bin/bash zabbix ; sudo passwd zabbix"
#        echo ""
#		exit
#fi

SCRIPTS=/usr/lib/zabbix/alertscripts/
DISTRO=/etc/redhat-release
PROJETO=Telegram-Graph-authenticated_Python
URLGIT=https://github.com/sansaoipb/$PROJETO

if [ -e $DISTRO ]
then
  sudo yum install -y jansson-devel openssl098e.x86_64 python34-libs libconfig-devel readline-devel libevent-devel lua-devel python-devel python3-devel python-pip python-pip3 python-requests python3-requests epel-release unzip git ; sudo ln -s /usr/lib64/liblua-5.1.so /usr/lib64/liblua5.2.so.0 ; sudo ln -s /usr/lib64/libcrypto.so.0.9.8e /usr/lib64/libcrypto.so.1.0.0
else
  sudo apt-get install -y libjansson-dev libreadline-dev libconfig-dev libssl-dev libevent-dev libjansson-dev libpython-dev libpython3-all-dev liblua5.2-0 python-pip python-pip3 python-requests python3-requests unzip git
fi

if [ ! -e $PROJETO ]
then
  git clone $URLGIT ; cd $PROJETO ; sudo unzip telegram.zip ; sudo rm -rf README.md ; sudo rm -rf telegram.zip ; cd telegram ; sudo chmod +x telegram-cli* ; cd /tmp/

fi


if [ -e $DISTRO ]
then
  cd $PROJETO/telegram ; sudo mv telegram-cli.CentOS telegram-cli
else
  cd $PROJETO/telegram ; sudo rm -rf telegram-cli.CentOS
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
  cd /tmp/$PROJETO/ ; sudo cp -R telegram* configScrips.properties $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x $PATHSCRIPTS/*.py ; cd .. ; sudo chown -R zabbix. *
else
  cd /tmp/$PROJETO/ ; sudo cp -R telegram* $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x $PATHSCRIPTS/*.py ; cd .. ; sudo chown -R zabbix. *
fi

sed -i "s,/etc/zabbix/scripts,$PATHSCRIPTS,g" $PATHSCRIPTS/telegram/telegram.config

sudo rm -rf /tmp/$PROJETO/

echo ""
echo "Acesse"
echo ""
echo "cd $PATHSCRIPTS/telegram ; sudo -u zabbix ./telegram-cli --rsa-key tg-server.pub --config telegram.config"
echo ""
echo "para começar a configuração"
echo ""
