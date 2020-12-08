# Overview

No escopo da aplicação, teremos uma interface para visualizar votações e enviar votos, um backend para receber os votos e inserir no banco de dados, além de listar as votações e resultados e no banco de dados temos o controle das votações ativas, opções de cada votação e o resultado agregado.

Neste cenário devemos definir que tipo de métricas são relevantes para serem armazenadas além de uma solução de coleta e monitoramento para o serviço como um todo.


# Métricas relevantes

Métricas servem para identificar tendências, sendo fundamentais para a organização e planejamento estratégico, para isso, é necessário escolher quais métricas serão utilizadas de acordo com as necessidades de cada área. Podemos usar métricas para avaliar produtividade, diagnosticar falhas e analisar o comportamento dos clientes.

Dito isto, para o cenário descrito, devemos nos preocupar tanto com a saúde da aplicação, quanto com os dados gerados pelos clientes que utilizam o produto.

Uma métrica muito relevante para identificar o comportamento dos clientes é o número de acessos à aplicação, este tido de dado é relevante pois além de medir o tráfego da sua aplicação, mede a taxa de interesse do usuário em prosseguir com a votação, já que é possível cruzar este dado com o número total de votos computados.

Além disso, caso a aplicação tenha um sistema de login, também é possível utilizar esta métrica num processo KDD, para identificar que tipo de usuário persiste na votação e qual deles visita o site e deixa de votar.

Outra métrica relevante que tem relação com o comportamento do usuário é o horário que ele utiliza a aplicação, caso o tráfego esteja concentrado em horários específicos, é possível configurar um ambiente com grande escalabilidade em função disso.

Além do horário, a localização do IP também é relevante, aplicações de monitoramento possuem funções para identificar da onde vem o request ao sistema e colocar num mapa. Este dado é relevante para, além de saber da onde seus usuários estão utilizando a aplicação, podemos identificar ataques ao sistema que visão manipular o resultado da votação, por exemplo, diversas requests vindas de IPs estrangeiros em padrões anormais, assim, seria simples para o administrador bloquear o bloco de IPs problemático.

Quanto a métricas mais técnicas, que tem relação com o desempenho do sistema, podemos citar a quantidade, tamanho e disponibilidade de cada recurso físico, o tamanho da página, o tempo de load da aplicação, número de itens por página, o número de erros funcionais, chamadas de API, número de execuções SQL, uso de RAM, número de requests da aplicação.

Todos estes dados são relevantes para monitorar a saúde da aplicação e estabelecer pontos em que ela pode ser otimizada.


# Soluções de monitoramento


Para o serviço como um todo, existem diversas soluções de monitoramento que podemos adotar, dentre combinações mais populares, podemos citar o Prometheus + Grafana e o ELK.

Propositalmente não será discutido o uso do Zabbix, já que ele já foi abordado em profundidade neste projeto, além de que, como veremos a frente, neste cenário possuimos opções com mais vantágens.

**Prometheus**

Prometheus é um sistema open-source para fazer o monitoramento e gerenciar alertas, podendo pegar métricas tanto do serviço quanto do banco de dados.

Prometheus também é altamente integrado ao kubernetes, logo, caso a aplicação tenha sido instalada num cluster kubernetes ele seria uma ótima opção.

Além disso, a instalação e configuração de um ambiente Prometheus + Grafana é extremamente simples e segura, mesmo que parte da infraestrutura para de funcionar, já que ele não precisa necessariamente de agentes para coletar métricas. Em caso de falha, apenas ele com o módulo Kube-System seria suficiente para coletar métricas do cluster.

Como desvantagens, podemos citar a necessidade de um storage elevado, e uma certa dificuldade para coletar métricas de jobs efêmeros.

A questão do storage pode levar o Prometheus a não ser uma solução tão boa a longo prazo, dependendo da quantidade de recusos disponíveis, porem, utilizar um serviço de hospedagem resolveria este problema.

**ELK**

O ELK é a combinação de 3 ferramentas: Elasticsearch, Logstash e Kibana. Juntos eles formam uma poderosa plataforma focada em buscar, analisar e visualizar logs de diferentes sistemas.

Desse trio, o elastcsearch atua como coração da ferramenta, sendo uma base de dados NoSQL distribuída, provendo analises de dados detalhadas.

O logstash centraliza o processamento dos dados, recebendo logs e eventos das fontes que ele monitora, os processando em seguida.

Kibana funciona como a ferramenta de visualização para o ELK, assim como o Grafana funcionaria pra o Prometheus.

Como desvantagem, podemos citar a complexidade da instalação, que é mais trabalhosa e demorada que a do Prometheus, além de um uso de memória intensivo, bem mais q o do Prometheus


# Comparação e escolha do melhor ambiente

A maior diferença entre o Prometheus e o ELK é o foco, Prometheus foca em detectar métricas e o ELK foca nos logs.

O cenário descrito aparenta ser uma aplicação que foca mais nas métricas que nos logs, além de não parecer ser tão complexa. Essas características somadas a facilidade de configurar e manter o ambiente Prometheus, tornam ele mais indicado para monitorar a situação descrita
