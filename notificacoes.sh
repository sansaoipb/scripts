#!/bin/bash
# ESCRITO POR SANSÃO

CMDLINE=$0
USER_ROOT=$(id | cut -d= -f2 | cut -d\( -f1)
command_out=$( /usr/bin/python3 -V 2>&1 )
command_rc=$?
#pythonVersion=$(/usr/bin/python3 -V 2>&1 | tr -d [:alpha:][:blank:] | cut -c 1-3)
pythonVersion=$(echo $command_out | tr -d [:alpha:][:blank:] | cut -c 1-3)
versioM=3.6

# Detecta se é um usuário com poderes de root que esta executando o script
#####################################################################################
if [ ! "$USER_ROOT" -eq 0 ] ; then
        echo ""
        echo "você deve ser root para executar este script, execute o comando:"
        echo ""
        echo "sudo bash $CMDLINE"
        echo ""
        exit 1

# Detecta se o python 3.6 ou superior existe no ambiente
#####################################################################################
elif [ $command_rc -ne 0 ]; then
        echo ""
        echo "Apontamento '/usr/bin/python3' não encontrado."
        echo "Instale/Aponte o '/usr/bin/python3.6' ou superior para '/usr/bin/python3' e reexecute o comando:"
        echo ""
        echo "sudo bash notificacoes.sh"
        echo ""
        exit 2

# Detecta se o apontamento para python3 está para python 3.6 ou superior.
#####################################################################################
elif [ 1 -eq "$(echo "${pythonVersion} < ${versioM}" | bc)" ] ; then
        echo ""
        echo "A versão apontada para o '/usr/bin/python3' é do \"Python $pythonVersion\"."
        echo "Instale/Atualize/Aponte para o python3.6 ou superior e reexecute o comando:"
        echo ""
        echo "sudo bash notificacoes.sh"
        echo ""
        exit 3
fi

echo ""
echo "Versão do '/usr/bin/python3' validada:"
echo "Apontado para \"$command_out\"."
echo ""
echo ""
echo ""
#exit 4

PATHSCRIPTS0="$(/usr/sbin/zabbix_server --help | grep "AlertScriptsPath" | awk '{ print $2 }' | tr -d "\"" | sed -e 's,/, ,g')"
PROJETO=Graphical_notifications_Zabbix
URLGIT=https://github.com/sansaoipb/$PROJETO
PATHPACKET=/usr/lib/zabbix
PATHSOURCE=/usr/local/share/zabbix

IFS=' ' read -a strarr <<< "$PATHSCRIPTS0"
delete=alertscripts
array=${strarr[@]/$delete}
PATHSCRIPTS=$(echo "/$array/" | sed -e 's, ,/,g')

#echo $PATHSCRIPTS
#exit 4


if [ ! -e $PATHPACKET ] ; then
  sudo mkdir /var/lib/zabbix/
fi


if [ ! -e $PATHSCRIPTS ] ; then
  sudo mkdir -p $PATHSCRIPTS0
fi


if [ -e $PATHPACKET ] ; then
   if [ ! -e $PATHSCRIPTS/alertscripts/ ] ; then
    sudo ln -s $PATHPACKET/alertscripts/ $PATHPACKET/externalscripts/ $PATHSCRIPTS

  fi
  sudo chown -R zabbix. $PATHPACKET

else
  if [ ! -e $PATHSCRIPTS/alertscripts/ ] ; then
    sudo ln -s $PATHSOURCE/alertscripts/ $PATHSOURCE/externalscripts/ $PATHSCRIPTS

  fi
  sudo chown -R zabbix. $PATHSOURCE
fi


#exit 4

curl https://bootstrap.pypa.io/get-pip.py | sudo -H python3

cd /tmp/ ; sudo chown -R zabbix. /var/lib/zabbix ; sudo -H -u zabbix python3 -m pip install wheel requests urllib3 pyrogram tgcrypto pycryptodome --user

if [ ! -e $PROJETO ] ; then
  git clone $URLGIT
fi



if [ ! -e "$PATHSCRIPTS/configScripts.properties" ] ; then
  sudo cp -R /tmp/$PROJETO/configScripts.properties $PATHSCRIPTS
fi

cd /tmp/$PROJETO/ ; sudo cp -R notificacoes* $PATHSCRIPTS ; cd $PATHSCRIPTS ; sudo chmod +x *.py ; dos2unix *.py ; cd .. ; sudo chown -R zabbix. * ; sudo rm -rf /tmp/$PROJETO/ ; sudo chown -R zabbix. $PATHSCRIPTS

#clear

echo ""
echo "Execute o comando abaixo para editar o arquivo de configuração:"
echo ""
echo "cd $PATHSCRIPTS ; sudo -u zabbix vim configScripts.properties"
echo ""
echo "e vamos começar com os envios"
echo ""
