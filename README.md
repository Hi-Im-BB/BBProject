# Overview
Este repositório contem a documentação de todos os Issues abertos durante o processo de desenvolvimento da aplicação, bem como a discussão das questões teóricas envolvendo o projeto.

O ambiente utilizado para o desenvolvimento do projeto foi um Cluster Kubernetes virtual utilizando o [Kind Cluster](https://kind.sigs.k8s.io/docs/user/quick-start/), que foi instalado numa máquina Windows via cholocatey.

	$ choco install kind

Para criar o cluster, basta utilizar o comando:

	$ kind create cluster


# Issue 1


Inicialmente foi localizada a [imagem docker oficial do zabbix 5.2 server](https://github.com/zabbix/zabbix-docker/blob/5.2/server-pgsql/ubuntu/Dockerfile), que foi modificada a fim de atender os requisitos do projeto.

A Dockerfile modificada pode ser encontrada em [`configuration/Dockerfile`](configuration/Dockerfile). A customização realizada nesta primeira etapa foi a implementação do um script [`down_detector.sh`](configuration/down_detector.sh) que é montado no diretório /usr/lib/zabbix/externalscripts/ dentro do container zabbix-server, bem como modificações nas permissões para que o usuário Zabbix possa ler e executar o script, como demonstrado abaixo.

	$ COPY  down_detector.sh  /usr/lib/zabbix/externalscripts/
	$ RUN  chown  zabbix.zabbix  /usr/lib/zabbix/externalscripts/down_detector.sh  &&\
	chmod  a+rx  /usr/lib/zabbix/externalscripts/down_detector.sh

Após realizado as modificações na Dockerfile, ela foi publicada no DockerHub em pedrosm/zabbix-bb.

	$ docker build . -t pedrosm/zabbix-bb
	$ docker push pedrosm/zabbix-bb

Em seguida foi decidido como seria o deploy do ambiente. Dentre diversas opções de ferramentas para automatizar a configuração do ambiente kubernetes, foi escolhido o Helm para este cenário, por ser uma ferramenta simples e otimizada para o deploy de aplicações no Kubernetes.

Helm pode ser visto como um DockerHub para a aplicações, nele podemos encontrar Artifacts, que são conjuntos de arquivos de configurações, para diversas aplicações, podendo ser customizados facilmente pelo arquivo values.yaml.

Para instalar o Helm no Windows via Chocolatey, utilize o comando:

	$ choco install kubernetes-helm

O Artifact escolhido para este projeto foi o [zabbix 0.2.1 · helm/cetic (artifacthub.io)](https://artifacthub.io/packages/helm/cetic/zabbix) de autoria do usuário cetic. Para ser adequado ao projeto proposto, alguns de seus componentes foram alterados como pode ser observado no arquivo  [`values.yaml`](values.yaml).

O repositório do zabbix server foi alterado para o repositório pessoal pedrosm/zabbix-bb customizado anteriormente, além disso, as tags dos demais repositórios foram alteradas para ubuntu-latest, para que fosse instalada a versão 5.2 do zabbix, já que por padrão, o artifact utiliza o zabbix 5.0.4.

Com os preparativos concluídos, foram realizados os seguintes passos para instalar o ambiente:

- Criar o namespace monitoring no Cluster Kubernetes

		$ kubectl create namespace monitoring
	
- Adicionar o repositório ao Helm
	
		$ helm repo add cetic https://cetic.github.io/helm-charts
		$ helm repo update
		
- Em seguida foi utilizado o arquivo values.yaml como parâmetro para realizar o deploy da aplicação no kubernetes

		$ helm install zabbix cetic/zabbix --dependency-update -f ./values.yaml -n moniroting

Com isso o cluster será montado com os seguintes componentes

- Pods:
	- zabbix-0 : Com o container do zabbix-server e zabbix-agent
	- zabbix-postgresql-0
	- zabbix-web : Utilizando a imagem web apache
- Serviços
	- zabbix-agent
	- zabbix-postgresql
	- zabbix-postgresql-headless
	- zabbix-server
	- zabbix-web
- Deployments
	- zabbix-web
- Replicaset
	- zabbix-web
- Statefulset
	- zabbix
	- zabbix-postgresql
  
 Todos estes dados podem ser adquiridos com o comando kubectl get all -n monitoring

Para acessar a interface web-apache, utilize o comando
			
	$  kubectl port-forward service/zabbix-web 8888:80 -n monitoring

O login e senha são os padrões do zabbix, Login: Admin, Senha: zabbix

Para deletar o ambiente

	$ helm delete zabbix -n monitoring

O script down_detector.sh, que foi instalado pela Dockerfile customizada durante a criação do cluster, é usado para coletar o status de serviços no site [Downdetector](https://downdetector.com/), e será utilizada para exemplificar a utilzação de external scripts no ambiente zabbix.

A parte mais relevante do código está na procura do campo "status:" e em seguida na coleta do dado encontrado neste campo.
	
	$  PAGINA="$(wget -q -O - https://downdetector.com/fora-do-ar/$1/)"
	$  STATUS=$(echo "$PAGINA" | grep "status:" | cut -d "'" -f2)

Para utilizar o script, iremos primeiro criar um novo host chamado Down Detector, e um novo grupo com o mesmo nome, faremos isso indo em Configuration - > Hosts - > Create Host.

![Alt text](images/dd1.png?raw=true "Criando Host Down Detector")

Em seguida em itens, iremos criar um novo item, utilizaremos o YouTube como exemplo, alterando o Type para External Check e adicionaro o script no campo Key, com o argumento youtube, down_detector.sh[youtube].

Também é necessário criar um novo value mapping para tratar as saídas do script, no caso, basta relacionar as saídas na forma: 1 = Up, 2 = Warning, 3 = Down. 

![Alt text](images/dd2.png?raw=true "Criando item Youtube")

Após aplicar as mudanças, basta executar as regras e verificar os dados saindo em Monitoring - > Latest Data

# Know issues

Caso o script tenha sido escrito numa máquina Windows, é possível que um erro " # /bin/bash^M: bad interpreter: No such file or directory", isso ocorre por causa de uma de registro da quebra de linha do Windows e no Linux, para resolver, basta utilizar:

	$   sed  -i  -e  's/\r$//'  meu_script.sh


# Issue 2

Nesta etapa iremos criar um serviço de monitoramento, utilizando inicialmente o script down_detector.sh, da instalação anterior.

Antes de iniciar, devemos considerar quais dados seriam relevantes de serem monitorados. O script foca em informar a saúde de um serviço, indicando seu status ( Up, Warning ou Down ), logo, outras informações relevantes a serem levantadas, seriam o código que a página web retorna, a velocidade de download e o tempo de resposta da página.

Também seria interessante criar alertas para caso alguma página esteja no estado de "Warning" ou 'Down", e para testar esta funcionalidade, foi propositalmente selecionada uma página que estava em um destes estados ( Chrunchyroll ) para criar um alerta.

Todos esses dados podem ser adquiridos via "icmppingsec", e para isso foi criado um novo item e um web scenario, com a chave icmppingsec[url do site a ser monitorado], como mostrado abaixo.

![Alt text](images/ytconnection.png?raw=true "Criando item Youtube Connection")
![Alt text](images/wcenarioyoutube.png?raw=true "Criando Web Scenario Youtube Connection")

Com isso, podemos adquirir dados de forma gráfica, como demonstrado abaixo:

![Alt text](images/graph.png?raw=true "Gráfico Youtube Connection")

Para fins ilustrativos, foram criados outros dois itens clonando os itens e cenários do youtube, para coletar dados do Instagram e do Chrunchyroll, também foram criados alertas para identificar quando um dos serviços cair.

![Alt text](images/warning.png?raw=true "Warning Chrunchyroll")

Finalizamos esta etapa criando uma interface de monitoramento como abaixo

![Alt text](images/dashboard.png?raw=true "Warning Chrunchyroll")

# Issue 2 - LLD e Expressões Regulares

Em seguida iremos criar uma interface básica com itens do Zabbix para ilustrar o uso de scripts lld e expressões regulares. O script foi desenvolvido pelo Pr. André Déo, fundador da comunidade brasileira de usuários Zabbix, e é uma ótima maneira de exemplificar o uso desse tipo de recurso de forma simples.

O script, que pode ser encontrado em [`lld_passwd.sh`](configuration/lld_passwd.sh), e o único requerimento para ser utilizado é a instalação do jq, um parser JSON. Ele coleta dados do /etc/passwd para gerar um arquivo JSON com macros para o Zabbix.

O script gera dois arquivox .txt na pasta /tmp/, um com as macros do Zabbix e outro no formato JSON para alimentar o Zabbix.

Para entender o script, precisamos entender o formato do arquivo passwd. Se usarmos o comando cat /etc/passwd, veremos uma lista de usuários que possuem o seguinte formato:

![Alt text](images/explaining-user-information.png?raw=true "User information")

Boa parte desses dados não tem relevância para o script, que irá buscar apenas os campos: User, Name, Home e Shell, e para cortar estes campos em variáveis, basta utilizar algumas expressões regulares, como mostrado abaixo:

	$ USER=$(cat /etc/passwd | cut -d: -f1)
	$ NOME=$(cat /etc/passwd | cut -d: -f5 | tr -d \")
	$ HOME=$(cat /etc/passwd | cut -d: -f6 | sed 's/\//\\\//g')
	$ SHELL=$(cat /etc/passwd | cut -d: -f7 | sed 's/\//\\\//g')

Na configuração do zabbix, basta colocar o script na pasta "External Scripts", e dar permissão de execução dentro da pasta e na pasta /tmp/ onde o script ira colocar seu output.

Em seguida, iremos criar um template e uma nova discovery rule, que irá utilizar o script instalado

![Alt text](images/llddiscovery.png?raw=true "Discovery Rule")

Depois, criaremos os item prototypes de cada opção do script, abaixo temos o exemplo criado pela opção HOME, basta clonar o item e substituir os dados com as outras variáveis.

![Alt text](images/prototype.png?raw=true "Criando prototypes")

Depois de criar os prototypes, basta criar um novo host e vincular este template, em alguns minutos, será possível ver os itens criados dentro do host pelo script.

![Alt text](images/itensfound.png?raw=true "Itens encontrados")

Abaixo também podemos ver os valores coletados em Monitoring -> Latest Data, filtando pelo nome root

![Alt text](images/rootfound.png?raw=true "LLD Latest Data")

Ao final temos uma interface de monitoramento geral simples, com dados do servidor zabbix, podemos exibir também os dados coletados pelo script.

![Alt text](images/generaldashboard.png?raw=true "Dashboard Genérico Simples")

# Issue 6
Nesta tarefa, temos uma situação hipotética, de uma aplicação que retorna o output no formato YAML. Devemos coletar a informação contida no campo "status" e caso ela seja diferente de "OK", criar um alerta no Zabbix.

Esta rotina se assemelha muito ao script down_detector.sh discutido nos Issues 1 e 2.

Para simular o recebimento do output da aplicação, iremos criar um arquivo output.yaml para que ele possa ser lido e tratado pelo script.
	
	$ yaml
	$ status: 'Fail'
	$ workers:
    $    -online:8
    $    -offline:1
	$ connections:
    $    -total: 87341
    $    -success: 87320
    $    -pending: 10
    $    -failed: 11

Neste arquivo simulamos um status diferente de OK para gerar o alerta, o script que ira checar o status é semelhante ao utilizado no down_detector.sh e pode ser visto abaixo.

	$ #!/bin/bash
	$ OUTPUT="$(cat /usr/lib/zabbix/externalscripts/output.yaml)"
	$ STATUS=$(echo "$OUTPUT" | grep "status:" | cut -d "'" -f2)
	$ if [ $STATUS == "OK" ]
	$ then
    $    echo "1"
	$ else
    $    echo "2"
	$ fi
O cenário propõe que a localidade do campo status é randômica, porém nesse script, independente do local em que o campo estiver no documento, será possível receber o valor do status. No caso, o script atribiu "OK" como 1, e qualquer outro valor como 2.

Assim como nos scripts anteriores, devemos alterar as permissões do arquivo para que o usuário zabbix possa o executar.

No Zabbix, devemos criar um novo item, e associar a ele um value map, no caso, caso o script retorne 1, sera mapeado para OK, e caso retorne 2, ALERT.

![Alt text](images/checkeritem.png?raw=true "Criando Item Checker")

![Alt text](images/checkerdt.png?raw=true "Criando Value Map")

Em seguida, basta criar o alerta no zabbix, que será acionado caso o valor retornado pelo script seja 2, como demonstrado abaixo.

![Alt text](images/checkeralert.png?raw=true "Criando Alerta")

Podemos ver na página de monitoramento padrão do zabbix o script funcionando

![Alt text](images/checkefinal.png?raw=true "Alerta funcionando")
