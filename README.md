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