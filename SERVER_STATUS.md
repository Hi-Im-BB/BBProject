# Monitoring the webserver

Na aplicação desenvolvida, foi utilizada a imagem do web-server apache postgresql.

Para adquirir métricas sobre acesso ao web-server, bem como outras informações úteis, basta configurar o módulo Apache MOD_STATUS e o arquivo de configuração 000-default.conf para permitir que a página server-status seja exibida.

# Tutorial

Inicialmente, busque o pod zabbix-web que hospeda o web-server apache com o comando:

	$ kubectl get pods -n monitoring

Em seguida use o comando abaixo e entre no pod

	$ kubectl exec --stdin --tty zabbix-web-64dd799659-4lvh9 -n monitoring -- /bin/bash

Busque o arquivo /etc/apache2/mods-enabled/status.conf, nele é possível configurar que apenas computadores dentro da sua rede acessem a página de status do servidor.

Em seguida, adicione a seguinte configuração no arquivo /etc/apache2/sites-enabled/000-default.conf

	$ <Location /server-status>
    $    SetHandler server-status
    $   Require local
    $    #Require ip < seu ip > # opcional
	$ </Location>
Para finalizar, basta reiniciar o serviço

	$ service apache2 restartq
Ao entrar em localhost:8888/server-status, você encontrara uma página semelhante a esta

![Alt text](images/server-status.png?raw=true "Página server-status")

Com isso, temos acesso a métricas como total de acessos, tráfico, uso de CPU, dentre outros.