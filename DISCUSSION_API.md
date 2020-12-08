# Discussion: Monitoring Problem

Um certo número de clientes deseja monitorar algum componente relativo a sua aplicação. Genericamente, a equipe de monitoramento tem acesso apenas a entrada, saída e documentação da aplicação, não possuindo conhecimento sobre sua funcionalidade.

# Brainstorm inicial & Estratégia

O cenário descrito, em que os dados disponíveis para trabalho são o input,output e documentação do projeto, encaminha o pensamento do desenvolvedor para a criação de uma API para solucionar a demanda do cliente, usando, por exemplo, Python e Python Flask para tratar as requisições e retornar apenas o dado relevante. 

Outra solução seria utilizando softwares de monitoramento como o NAGIOS, um ambiente de teste para ativos de TI, entretanto, uma análise pontual da demanda indica que o método utilizando API, por ser mais focado nos projetos individuais, sem colocar uma interface com todos os elementos da rede para o usuário, seria mais eficiente.


Utilizando métodos ágeis, uma forma correta de lidar com este tipo de demanda seria estruturar o problema utilizando as etapas de: Design de Testes, Avaliação dos resultados obtidos e Homologação ( Entrega + Aceite ) para o cliente.

# Entrevista com o cliente

Diante de uma demanda, a primeira ação seria a entrevista com o cliente, para questionar quais formas de falha são comuns e quais os critérios ele definiria para a aceitação do produto. Outros dados importantes a serem investigados durante a interação, seria a frequência e o volume da demanda do produto.

Com esses dados, seria feito um processo automatizado para fazer os testes nessa frequência, tais testes dependeriam de:
- Uma interpretação da interface e dos resustados esperados;
- Criação de um desenho de solução;
- Realização manual dos testes;
- Automação dos testes;
- Avaliação técnica dos resultados obtidos;
- Criação de um relatório de conclusão;
- Entrega dos resultados

# Prazos & Entregáveis

O prazo para a entrega do produto deve ser combinado com o usuário, levando em conta o tamanho e complexidade da interface, os entregáveis poderiam ser divididos de acordo com os serviços prestados pela API, sendo a entrega de um ou mais serviços por semana, dependendo da complexidade de cada um.

Caso a demanda seja simples, com poucos serviços a serem implementados pela API, é possível que a entrega da aplicação completa seja feita no período de uma semana. No caso de um numero elevado de serviços a serem considerados ou no caso de serviços mais complexos, seriam entregues alguns deles por semana, sendo o número levantado junto ao cliente e o especialista designado.

# Homologação

Ao final de cada etapa, deve ser feita a homologação, em que o cliente recebe o entregável e envia o feedback, sendo ele na forma de aceite, onde o cliente se mostra satisfeito com o resultado e a equipe encaminha seus esforços para o entregável seguinte, ou recusa, onde a equipe deve reformular a solução oferecida.
