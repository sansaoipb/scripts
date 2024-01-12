#!/bin/bash
# ESCRITO POR SANSÃO

versionM=3.9
CMDLINE=$0
USER_ROOT=$(id | cut -d= -f2 | cut -d\( -f1)
pythonVersion=$( /usr/bin/python3 -V 2>&1 )
command_rc=$?

versionP=$(echo $pythonVersion | cut -d' ' -f2 | cut -d. -f1,2)
pathPIP=$(/usr/bin/which pip3 2>&1 )

versionP2=$(echo $versionP | cut -d. -f2)
versionM2=$(echo $versionM | cut -d. -f2)

# Detecta se é um usuário com poderes de root que esta executando o script
#####################################################################################
if [ ! "$USER_ROOT" -eq 0 ] ; then
        echo ""
        echo "você deve ser root para executar este script, execute o comando:"
        echo ""
        echo "sudo bash $CMDLINE"
        echo ""
        exit 1

# Detecta se o python 3.9 ou superior existe no ambiente
#####################################################################################
elif [ $command_rc -ne 0 ]; then
        echo ""
        echo "Apontamento '/usr/bin/python3' não encontrado."
        echo "Instale/Aponte o '/usr/bin/python3.9' ou superior para '/usr/bin/python3' e reexecute o comando:"
        echo ""
        echo "sudo bash notificacoes.sh"
        echo ""
        exit 2

# Detecta se o apontamento para python3 está para python 3.9 ou superior.
#####################################################################################
elif [ 1 -eq "$(echo "${versionP2} < ${versionM2}" | bc)" ] ; then
        echo ""
        echo "A versão apontada para o '/usr/bin/python3' é do \"$pythonVersion\"."
        echo "Instale/Atualize/Aponte para o python3.9 ou superior e reexecute o comando:"
        echo ""
        echo "sudo bash notificacoes.sh"
        echo ""
        exit 3
fi

echo ""
echo ""
echo "Versão do '/usr/bin/python3' validada:"
echo "Apontado para \"$pythonVersion\"."
echo ""
echo ""


if [ -z $pathPIP ] ; then
  curl https://bootstrap.pypa.io/get-pip.py | sudo -H python3

else
  pipVersion=$($pathPIP -V | cut -f 6 -d ' ' | tr -d [=\)=])
  if [ 1 -eq "$(echo "${pipVersion} < ${versionM}" | bc)" ] ; then
    curl https://bootstrap.pypa.io/get-pip.py | sudo -H python3

  fi
fi

pathPIP=$(/usr/bin/which pip$versionP 2>&1)
ln -sf $pathPIP /usr/bin/pip3


PATHSCRIPTS0="$(/usr/sbin/zabbix_server --help | grep "AlertScriptsPath" | awk '{ print $2 }' | tr -d "\"")"
PROJETO=Graphical_notifications_Zabbix
URLGIT=https://github.com/sansaoipb/$PROJETO
MODULOS=/var/lib/zabbix
PATHPACKET=/usr/lib/zabbix
PATHSOURCE=/usr/local/share/zabbix

PATHS=$PATHSCRIPTS0
delete=alertscripts
ARRAY=${PATHS[@]/$delete}
PATHSCRIPTS=$ARRAY


if [ ! -e $MODULOS ] ; then
  sudo mkdir -p $MODULOS

fi

if [ ! -e $PATHSCRIPTS ] ; then
  sudo mkdir -p $PATHSCRIPTS

fi


if [ -e $PATHPACKET ] ; then
   if [ ! -e $PATHSCRIPTS0 ] ; then
    sudo ln -s $PATHPACKET/alertscripts/ $PATHPACKET/externalscripts/ $PATHSCRIPTS

  fi
  sudo chown -R zabbix:zabbix $PATHPACKET

else
  if [ ! -e $PATHSCRIPTS0 ] ; then
    sudo ln -s $PATHSOURCE/alertscripts/ $PATHSOURCE/externalscripts/ $PATHSCRIPTS

  fi
  sudo chown -R zabbix:zabbix $PATHSOURCE
fi

cd /tmp/ ; sudo chown -R zabbix:zabbix $MODULOS ; sudo -H -u zabbix /usr/bin/pip3 install wheel requests urllib3 pyrogram tgcrypto pycryptodome --user -U


if [ ! -e $PROJETO ] ; then
  git clone $URLGIT
fi


if [ ! -e "$PATHSCRIPTS0/configScripts.properties" ] ; then
  sudo cp -R /tmp/$PROJETO/configScripts.properties $PATHSCRIPTS0
fi

cd /tmp/$PROJETO/ ; sudo cp -R notificacoes* $PATHSCRIPTS0 ; cd $PATHSCRIPTS0 ; sudo chmod +x *.py ; dos2unix *.py ; sudo rm -rf /tmp/$PROJETO/ ; sudo chown -R zabbix:zabbix $PATHSCRIPTS $PATHSCRIPTS0

echo ""
echo "Execute o comando abaixo para editar o arquivo de configuração:"
echo ""
echo "cd $PATHSCRIPTS0 ; sudo -u zabbix vim configScripts.properties"
echo ""
echo "e vamos começar com os envios"
echo ""
