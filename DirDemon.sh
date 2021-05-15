#!/bin/bash

###################################################################
# Nome; DirDemon
# Owner: vida
# Contato: vidaᶜʸᵇᵉʳ#6443
# Testado no: Kubuntu
# Criado em: 22/01/2021 em um dia chuvoso ouvindo Mozart
# Funçao: Um canivete suiço para achar diretorios e arquivos
###################################################################

###################################################################
# -> Versao
###################################################################
versao='0.1'

###################################################################
# -> Ctrl + C
###################################################################
trap Ctrl_C INT
Ctrl_C(){
	echo -e "${vermelho}\nACAO ABORTADA${end}"
	exit 1
}

###################################################################
# -> Constantes para facilitar o uso das cores
###################################################################
roxo="\033[35;01;1m"
cinza="\033[30;01;1m"
vermelho="\033[31;01;1m"
end="\033[m"

###################################################################
# -> Variaveis para armazenar os argumentos
###################################################################
op=$1		# opcao escolhida pelo user
alvo=$2		# alvo a ser atacado
wd=$4		# wordlist a ser usada
ext=$6		# extensao a ser procurada
op2=$5		# opcao de uso
op3=$7		# opcao de uso se esolher bf em ext

###################################################################
# -> Banner
###################################################################
Banner(){
	echo -e "      ${vermelho}|${end}${cinza}_${end}${vermelho}|${end}   ${vermelho},,,${end}"
	echo -e "     ${cinza}(${end}${vermelho}'.'${end}${cinza})${end}${vermelho} ///${end}\t${cinza}Have a nice experience${end}"
	echo -e "     ${cinza}<(_)-${end} ${vermelho}/${end}\t${cinza}Codado por vida.${end}"
	echo -e " ${vermelho}<${end}${cinza}-._/J L${end} ${vermelho}/${end}\t${cinza}$0 -h${end}"
}
###################################################################
# -> Menu De Ajuda
###################################################################
Help(){
	echo -e "${cinza}"
	echo -e "\t╦ ╦╔═╗╦  ╔═╗"
	echo -e "\t╠═╣║╣ ║  ╠═╝"
	echo -e "\t╩ ╩╚═╝╩═╝╩\n"
	echo -e "\tO DirDemon faz: bruteforce para achar diretorios, arquivos, e arquivos com extensoes especificas\n"
	echo -e "\t-h, --help			Mostra o menu de ajuda"
	echo -e "\t-v, --version		Mostra a versao do software"
	echo -e "\t-a, --alvo		  	Define o alvo (Dominio/IP)"
	echo -e "\t-w, --wordlist		Define a wordlist a ser usada"
	echo -e "\t-e, --extensao		Define a extensao a ser procurada"
	echo -e "\n\t\t\tOpcoes:\n\t--dirbrute, Executara apenas o bruteforce de diretorios\n\t--arqbrute, Executara apenas o bruteforce de arquivos\n\t--extbrute, Executara apenas o bruteforce de arquivos com extensoes especificas"
	echo -e "\n\t\t\tExemplos:\n\t$0 -a example.com -w wordlist.txt -e php -> Executara todos os BruteForce\n\t$0 -a example.com -w wordlist.txt --dirbrute -> Executara o BruteForce de diretorios\n\t$0 -a example.com -w wordlist.txt --arqbrute -> Executara o BruteForce de Arquivos\n\t$0 -a example.com -w wordlist.txt -e php --extbrute -> Executara apenas o BruteForce de arquivos com extensoes especificas"
	echo -e "${end}"
}

###################################################################
# -> Verifica (Dependencias e Argumentos)
###################################################################
Verifica(){
	#Verifica Dependencias
	if ! [[ -e /usr/bin/curl ]];then
		echo -e "${vermelho}[!] Dependencia: curl${end}\nsudo apt install curl"
		exit 1
	elif ! [[ -e /usr/bin/host ]];then
		echo -e "${vermelho}[!] Dependencia: host${end}\nsudo apt install host"
		exit 1
	fi

	#Verifica Argumentos
	if [ -z "$op" ];then
		Banner
		exit 1
	fi
}

###################################################################
# -> Verifica as opcoes
###################################################################
Verifica_Opcoes(){
	if [ -z "$alvo" ];then Help;exit 1;fi
	if [ -z "$wd" ];then Help;exit 1;fi
	if [ ! -s "$wd" ];then echo -e "${cinza}Wordlist Inexistente${end}";exit 1;fi
}
Verifica_Opcoes_Arq(){
	if [ -z "$alvo" ];then Help;exit 1;fi
	if [ -z "$wd" ];then Help;exit 1;fi
	if [ -z "$ext" ];then Help;exit 1;fi
	if [ ! -s "$wd" ];then echo -e "${cinza}Wordlist Inexistente${end}";exit 1;fi
}

###################################################################
# -> Verifica o Alvo
###################################################################
Verifica_Host(){
	#Verifica Host
	verifica=$(host $alvo 2>/dev/null | cut -d "(" -f2 | cut -d ")" -f1)
	if [ "$verifica" == "NXDOMAIN" ] && [ "$verifica" == "SERVFAIL" ];then
		echo -e "${vermelho}[!] HOST INDISPONIVEL${end}"
		exit 1
	fi
}

###################################################################
# -> Array pra armazenar user agents
###################################################################
agents=("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.135 Safari/537.36")

###################################################################
# -> Funcoes do DirDemon
###################################################################
DirDemon_DirBruto(){
	echo -e "${cinza} ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯ ${end}"
	echo -e "${roxo}  ⛧ Diretorios⛧ ${end}"
	echo -e "${cinza} ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯ ${end}"
	for dir in $(cat $wd);do
		echo -e "${roxo} [+] Exorcizando: $alvo/$dir${end}" | tr '\n' '\r'
		for num in $(seq 0 2);do
			dirbruto=$(curl -s -o /dev/null -w "%{http_code}" -H "User-Agent: ${agents[$num]}" $alvo/$dir/)
		done
		if [ $dirbruto -ne "404" ] && [  $dirbruto -ne "301" ];then
			echo -e "${roxo} [+] Diretorio Exorcizado: $alvo/$dir/${end} ${cinza}[CODE:$dirbruto]${end}"
		fi
	done
	echo -e "\n${cinza} --END--${black}"
}
DirDemon_ArqBruto(){
	echo -e "${cinza} ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯ ${end}"
	echo -e "${roxo}  ⛧ Arquivos⛧ ${end}"
	echo -e "${cinza} ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯ ${end}"
	for arq in $(cat $wd);do
		echo -e "${roxo} [+] Exorcizando: $alvo/$arq${end}" | tr '\n' '\r'
		for num in $(seq 0 2);do
			arqbruto=$(curl -s -o /dev/null -w "%{http_code}" -H "User-Agent: ${agents[$num]}" $alvo/$arq)
		done
		if [ $arqbruto -ne "404" ] && [  $arqbruto -ne "301" ];then
			echo -e "${roxo} [+] Arquivo Exorcizado: $alvo/$arq${end} ${cinza}[CODE:$arqbruto]${end}"
		fi
	done
	echo -e "\n${cinza} --END--${black}"
}
DirDemon_ExtBruto(){
	echo -e "${cinza} ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯ ${end}"
	echo -e "${roxo}  ⛧ Arquivos $ext⛧ ${end}"
	echo -e "${cinza} ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯ ${end}"
	for name in $(cat $wd);do
		echo -e "${roxo} [+] Exorcizando: $alvo/$name.$ext${end}" | tr '\n' '\r'
		for num in $(seq 0 2);do
			extbruto=$(curl -s -o /dev/null -w "%{http_code}" -H "User-Agent: ${agents[$num]}" $alvo/$name.$ext)
		done
		if [ $extbruto -ne "404" ] && [  $extbruto -ne "301" ];then
			echo -e "${roxo} [+] $ext Exorcizado: $alvo/$name.$ext${end} ${cinza}[CODE:$extbruto]${end}"
		fi
	done
	echo -e "\n${cinza} --END--${black}"
}

###################################################################
# -> Banner ao inciar o Script
###################################################################
Banner_Info(){
	webserver=$(curl --head -s $alvo | grep "Server" | cut -d " " -f2)
	echo -e "${cinza} ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${end}"
	echo -e "${cinza} ┃ ⸸ DirDemon v0.1 ${end}"
	echo -e "${cinza} ┃ ⸸ Alvo: $alvo   ${end}"
	echo -e "${cinza} ┃ ⸸ WebServer: $webserver ${end}"
	echo -e "${cinza} ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${end}"
}

###################################################################
# -> Main
###################################################################
Main(){
	Verifica
	case $op in
		"-h"|"--help")
			Help
			exit 0
		;;
		"-v"|"--versao")
			echo -e "${cinza}Versao do DirDemon: $versao${end}"
			exit 0
		;;
		"-a"|"--alvo")
			Verifica_Host
			Banner_Info
			if [ "$op2" == "--dirbrute" ];then Verifica_Opcoes;DirDemon_DirBruto;exit 0;fi
			if [ "$op2" == "--arqbrute" ];then Verifica_Opcoes;DirDemon_ArqBruto;exit 0;fi
			if [ "$op3" == "--extbrute" ];then Verifica_Opcoes_Arq;DirDemon_ExtBruto;exit 0;fi
			if [ -z "$op3" ];then Verifica_Opcoes_Arq;DirDemon_DirBruto;DirDemon_ArqBruto;DirDemon_ExtBruto;exit 0;fi
		;;
		*)
			Help
			exit 0
		;;
	esac
}

###################################################################
# -> Executando o DirDemon					  #
###################################################################
Main

