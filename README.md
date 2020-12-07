# BBProject
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

![Alt text](images/checkerfinal.png?raw=true "Alerta funcionando")