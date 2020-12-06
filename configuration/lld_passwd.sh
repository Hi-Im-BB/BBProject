#!/bin/bash

#######################################################################################
# Definicao de Variaveis:                                                             #
# Estou usando passagem de parametros, mas nada de impede de definir os valores aqui. #
#######################################################################################

USER=$(cat /etc/passwd | cut -d: -f1)
NOME=$(cat /etc/passwd | cut -d: -f5 | tr -d \")
HOME=$(cat /etc/passwd | cut -d: -f6 | sed 's/\//\\\//g')
SHELL=$(cat /etc/passwd | cut -d: -f7 | sed 's/\//\\\//g')
LINHAS=$(echo "$USER" | wc -l)

case $1 in
discovery)
rm -rf /tmp/lld_passwd.txt
echo -e "{" >> /tmp/lld_passwd.txt
echo -e "\t\"data\":[\n" >> /tmp/lld_passwd.txt
for ((i=1; i<$LINHAS; i++))
do
	echo -e "\t{" >> /tmp/lld_passwd.txt
	echo -e "\t\t\"{#USER}\":\"`echo "$USER" | head -$i | tail -1`\"," >> /tmp/lld_passwd.txt
	echo -e "\t\t\"{#NOME}\":\"`echo "$NOME" | head -$i | tail -1`\"," >> /tmp/lld_passwd.txt
	echo -e "\t\t\"{#HOME}\":\"`echo "$HOME" | head -$i | tail -1`\"," >> /tmp/lld_passwd.txt
	echo -e "\t\t\"{#SHELL}\":\"`echo "$SHELL" | head -$i | tail -1`\"" >> /tmp/lld_passwd.txt
	echo -e "\t}" >> /tmp/lld_passwd.txt
	echo -e "\t," >> /tmp/lld_passwd.txt
done


#######################################################################################
# Acabei de montar do primeiro ao penultimo registro				      #
# agora vou montar o ultimo e fechar o arquivo JSON				      #
#######################################################################################
	echo -e "\t{" >> /tmp/lld_passwd.txt
	echo -e "\t\t\"{#USER}\":\"`echo "$USER" | head -$LINHAS | tail -1`\"," >> /tmp/lld_passwd.txt
	echo -e "\t\t\"{#NOME}\":\"`echo "$NOME" | head -26 | tail -1`\"," >> /tmp/lld_passwd.txt
	echo -e "\t\t\"{#HOME}\":\"`echo "$HOME" | head -26 | tail -1`\"," >> /tmp/lld_passwd.txt
	echo -e "\t\t\"{#SHELL}\":\"`echo "$SHELL"  | head -$LINHAS | tail -1`\"" >> /tmp/lld_passwd.txt
	echo -e "\t}\n" >> /tmp/lld_passwd.txt

echo -e "\t]" >> /tmp/lld_passwd.txt
echo -e "}\n" >> /tmp/lld_passwd.txt


#######################################################################################
# Acabei de gerar o JSON com as variaveis que o Zabix precisa			      #
# Mostro o conteudo na tela							      #
#######################################################################################
cat /tmp/lld_passwd.txt


#######################################################################################
# Gero o JSON no formato normal para ser usado pelo comando "jq"		      #
#######################################################################################
sed 's/{\#USER}/user/g' /tmp/lld_passwd.txt |  sed 's/{\#NOME}/nome/g' |  sed 's/{\#HOME}/home/g' |  sed 's/{\#SHELL}/shell/g' > /tmp/lld_passwd_2.txt
;;

user) cat /tmp/lld_passwd_2.txt | jq ".data[] | select(.user == \"$2\") | .user"
;;
nome)  cat /tmp/lld_passwd_2.txt | jq ".data[] | select(.user == \"$2\") | .nome"
;;
home)  cat /tmp/lld_passwd_2.txt | jq ".data[] | select(.user == \"$2\") | .home"
;;
shell)  cat /tmp/lld_passwd_2.txt | jq ".data[] | select(.user == \"$2\") | .shell"
;;
*) echo "Use discovery, user, nome, home  ou shell";;
esac
