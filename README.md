### Monitoramento de tamanho de banco de dados e tabelas Postgresql

Esse projeto visa efetuar o monitoramento dos tamanhos de databases e tabelas do postgresql, sendo que a saida dos scripts será em json compativel com o zabbix.

É necessario que o usuario de conexão ao banco esteja configurado como trust no arquivo pg_hba.conf.



## Configuração do userparameters:

```bash
# Descoberta de Bancos de Dados
UserParameter=pgsql.discovery.db[*],/etc/zabbix/scripts/pg_discovery_db.sh $1

# Coleta de Tamanho de um Banco de Dados
UserParameter=pgsql.size.db[*],/etc/zabbix/scripts/pg_size_db.sh $1 $2

# Descoberta de Tabelas dentro de um Banco de Dados
UserParameter=pgsql.discovery.tables[*],/etc/zabbix/scripts/pg_discovery_tables.sh $1 $2

# Coleta de dados de todas as Tabelas (para o item mestre)
UserParameter=pgsql.data.tables[*],/etc/zabbix/scripts/pg_size_tables.sh $1 $2

```


## Configuração de Itens no zabbix:

A. Crie o Template para Bancos de Dados (Nível 2)
Vamos começar criando o template que será aplicado aos bancos de dados descobertos.

Vá em Configuração → Templates → Criar template.

Nome do Template: Template App PostgreSQL Database

Grupo: Templates/Databases

Clique em Adicionar.

Agora, dentro deste novo template, vamos configurar a descoberta de tabelas (L2).

Clique no template Template App PostgreSQL Database para editá-lo.

Vá em Regras de Descoberta → Criar regra de descoberta.

Nome: L2 - Descoberta de Tabelas

Tipo: Item dependente

Vá para a aba Protótipos de Itens dentro desta regra e siga o padrão de "Item Mestre" que fizemos antes.

Nota: A forma mais moderna e eficiente é ter um item mestre no template e a regra de descoberta e os protótipos de itens dependerem dele. Isso evita complexidade.

Vamos simplificar e criar o item mestre primeiro:

Saia da regra de descoberta e vá para Itens dentro do template.

Criar Item (Este será o Item Mestre para os dados das tabelas).

Nome: Coleta de dados das Tabelas

Tipo: Agente Zabbix

Chave: pgsql.data.tables[/etc/zabbix/scripts/pg_monit.conf,{HOST.NAME}]

{HOST.NAME} é uma macro do Zabbix que será resolvida para o nome do host descoberto (ex: siva).

Tipo de informação: Texto.

Intervalo de atualização: 1h.

Agora volte para Regras de Descoberta, edite a regra L2 - Descoberta de Tabelas.

Tipo: Item dependente.

Item Mestre: Selecione o item que acabamos de criar (Coleta de dados das Tabelas).

Pré-processamento: Adicione um passo JSONPath com o parâmetro $.data.

Dentro da regra L2, vá para Protótipos de Itens. Crie um protótipo para cada métrica:

Exemplo para "Tamanho Total":

Nome: Tamanho Total: {#TABLENAME}

Tipo: Item dependente.

Item Mestre: Coleta de dados das Tabelas.

Chave: pgsql.table.totalsize[{#TABLENAME}].

Tipo de informação: Numérico (inteiro sem sinal).

Unidades: B.

Pré-processamento: Adicione um passo JSONPath com $.data[?(@.['{#TABLENAME}']=='{#TABLENAME}')].['{#TOTALSIZE}'].

B. Configure o Host Principal e a Descoberta de Bancos (Nível 1)
Agora vamos ao host que representa a instância do PostgreSQL.

Vá em Configuração → Hosts → (Seu host do PostgreSQL).

Vá em Regras de descoberta → Criar regra de descoberta.

Nome: L1 - Descoberta de Bancos de Dados

Tipo: Agente Zabbix

Chave: pgsql.discovery.db[/etc/zabbix/scripts/pg_monit.conf]

Intervalo de atualização: 1h.

Dentro desta regra L1, vá para a aba Protótipos de Itens.

Vamos criar aqui o protótipo para o item de tamanho do banco de dados.

Criar protótipo de item:

Nome: Tamanho do Banco de Dados: {#DBNAME}

Tipo: Agente Zabbix

Chave: pgsql.size.db[/etc/zabbix/scripts/pg_monit.conf,{#DBNAME}]

Tipo de informação: Numérico (inteiro sem sinal).

Unidades: B.

Dentro da mesma regra L1, vá para a aba Protótipos de Host.

Criar protótipo de host:

Nome do Host: {#DBNAME}

Nome visível: PostgreSQL: {#DBNAME}

Templates: Na aba de Templates, clique em Adicionar e vincule o template que criamos na etapa A (Template App PostgreSQL Database).

Grupos de hosts: Adicione a um grupo, como Discovered hosts/Databases.

