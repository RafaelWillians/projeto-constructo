#!/bin/bash

# Script de instalacao do Zabbix 7.2 (server, frontend, agent, com postgresql e apache) no container Ubuntu Noble

# !!! Revisar !!!
# Instalar o curl e wget
sudo apt update -y
sudo apt install -y curl
sudo apt install -y wget
# !!! Revisar !!!

# Checa o status do apache
sudo systemctl status apache2

# Instala o apache
sudo apt install -y apache2

# Instala os componentes necessarios
sudo apt install -y php php-{cgi,common,mbstring,net-socket,gd,xml-util,mysql,bcmath,imap,snmp}
sudo apt install -y libapache2-mod-php
sudo apt update -y
sudo apt install -y postgresql

# Checa se o usuario postgres foi criado
getent passwd postgres

# Inicia o servico do Postgre
sudo systemctl start postgresql

# Instalar o repositório Zabbix
sudo wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
sudo apt update -y

# Instala o servidor, frontend e agente do Zabbix
sudo apt install -y zabbix-server-pgsql zabbix-frontend-php php8.3-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

# Cria o banco de dados no postgre
# sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres psql -c "CREATE USER zabbix WITH PASSWORD 'zabbix';"
sudo -u postgres createdb -O zabbix zabbix

# Checar manualmente o banco de dados
# sudo su - postgres
# psql
# \l # Checar se o banco de dados zabbix esta criado
# \du # Checar se o usuario esta criado
# \q # Sai do postgre

# Importa o esquema inicial e os dados
zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

# Configura o banco de dados para o servidor Zabbix

sudo grep -q '^DBPassword=' /etc/zabbix/zabbix_server.conf || echo 'DBPassword=zabbix' | sudo tee -a /etc/zabbix/zabbix_server.conf

# Manual:
# sudo nano /etc/zabbix/zabbix_server.conf
# Tirar o comentário do texto DBPassword= e inserir uma senha após o =
# Salvar pressionando CTRL+letra O


# Reinicia e habilita o servidor e agent do Zabbix
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

# Depois, basta abrir no navegador digitando localhost/zabbix ou <hostname>/zabbix
xdg-open http://localhost/zabbix