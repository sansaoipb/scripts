#!/bin/bash
# ESCRITO POR SANSÃO

# Detecta se é um usuário com poderes de root que esta executando o script
#####################################################################################
CMDLINE=$0
USER_ROOT=$(id | cut -d= -f2 | cut -d\( -f1)
if [ ! "$USER_ROOT" -eq 0 ] ; then
        echo "\nvocê deve ser root para executar este script."
        echo "execute o comando \"sudo sh $CMDLINE\"\n"
        exit 1
fi
#####################################################################################


# Detecta se o python 3.6 ou superior existe no ambiente
#####################################################################################
command_out=$( /usr/bin/python3 -V 2>&1 )
command_rc=$?
if [ $command_rc -ne 0 ]; then
        echo "\nApontamento '/usr/bin/python3' não encontrado.\nInstale/Aponte o '/usr/bin/python3.6' ou superior para '/usr/bin/python3' e reexecute o comando:\n\nsudo sh notificacoes.sh\n"
        exit 2
fi
#####################################################################################


# Detecta se o apontamento para python3 está para python 3.6 ou superior.
#####################################################################################
pythonVersion=$(/usr/bin/python3 -V 2>&1 | tr -d [:alpha:][:blank:] | cut -c 1-3)
versioM=3.6

if [ 1 -eq "$(echo "${pythonVersion} < ${versioM}" | bc)" ] ; then
        echo "\nA versão apontada para o '/usr/bin/python3' é do \"Python $pythonVersion\".\nInstale/Atualize/Aponte para o python3.6 ou superior e reexecute o comando:\n\nsudo sh notificacoes.sh\n"
        exit 3
fi
#####################################################################################

PATHSCRIPTS="$(/usr/sbin/zabbix_server --help | grep "AlertScriptsPath" | awk '{ print $2 }' | tr -d "\"")/"
PROJETO=Graphical_notifications_Zabbix
URLGIT=https://github.com/sansaoipb/$PROJETO
MODULOS=/var/lib/zabbix/

curl https://bootstrap.pypa.io/get-pip.py | sudo -H python3

if [ ! -e $MODULOS ]
then
  cd /tmp/ ; sudo mkdir /var/lib/zabbix/ ; sudo chown -R zabbix. /var/lib/zabbix ; sudo -H -u zabbix python3 -m pip install wheel requests urllib3 pyrogram tgcrypto pycryptodome --user
else
  cd /tmp/ ; sudo chown -R zabbix. /var/lib/zabbix ; sudo -H -u zabbix python3 -m pip install wheel requests urllib3 pyrogram tgcrypto pycryptodome --user
fi

if [ ! -e $PROJETO ]
then
  git clone $URLGIT
fi

cd $PATHSCRIPTS

if [ ! -e "configScripts.properties" ]
then
  cd /tmp/$PROJETO/ ; sudo cp -R notificacoes* configScripts.properties $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x *.py ; dos2unix *.py ; cd .. ; sudo chown -R zabbix. *

else
  cd /tmp/$PROJETO/ ; sudo cp -R notificacoes* $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x *.py ; dos2unix *.py ; cd .. ; sudo chown -R zabbix. *
fi

sudo rm -rf /tmp/$PROJETO/

#clear

echo ""
echo "Execute o comando abaixo para editar o arquivo de configuração:"
echo ""
echo "cd $PATHSCRIPTS ; vim configScripts.properties"
echo ""
echo "e vamos começar com os envios"
echo ""
