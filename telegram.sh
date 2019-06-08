#!/bin/bash
# ESCRITO POR SANSAO

# Detecta se esta logado com usuario zabbix
################################################################################
if [ `whoami` != "zabbix" ] ; then
        echo ""
        echo "voce deve estar logado com o user zabbix para continuar."
        echo "Se nunca logou com ele, execute o comando em seguida logue"
        echo ""
        echo "sudo usermod -s /bin/bash zabbix ; sudo passwd zabbix"
        echo ""
		exit
fi
################################################################################

SCRIPTS=/usr/lib/zabbix/alertscripts/
PROJETO=Email-Graph-ZABBIX_Python
URLGIT=https://github.com/sansaoipb/$PROJETO


if [ ! -e $PROJETO ]
then
  git clone $URLGIT
fi

cd $PROJETO ; sudo rm -rf README.md ; cd /tmp/

if [ -e $SCRIPTS ]
then
  PATHSCRIPTS=/usr/lib/zabbix/alertscripts
else
  PATHSCRIPTS=/usr/local/share/zabbix/alertscripts
fi

cd $PATHSCRIPTS

if [ ! -e "configScrips.properties" ]
then
  cd /tmp/$PROJETO ; sudo cp -R *.py configScrips.properties $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x $PATHSCRIPTS/*.py ; cd .. ; sudo chown -R zabbix. *
else
  cd /tmp/$PROJETO ; sudo cp -R *.py $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x $PATHSCRIPTS/*.py ; cd .. ; sudo chown -R zabbix. *
fi

sudo rm -rf /tmp/$PROJETO/

echo ""
echo "Acesse"
echo ""
echo "cd $PATHSCRIPTS/"
echo ""
echo "para começar a configuração"
echo ""
