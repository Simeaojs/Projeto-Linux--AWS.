#!/bin/bash

# Atualizar o sistema
sudo yum update -y

# Instalar o Apache
sudo yum install httpd -y

# Iniciar o Apache
sudo systemctl start httpd

# Habilitar o Apache para iniciar na inicialização do sistema
sudo systemctl enable httpd

# Definir permissões para a pasta do Apache (substitua "/var/www/html" pelo seu diretório específico)
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Criar um arquivo index.html de exemplo (opcional)
echo "<html><body><h1>Meu Site Apache</h1></body></html>" | sudo tee /var/www/html/index.html

# Reiniciar o Apache para aplicar as alterações
sudo systemctl restart httpd

# Verificar o status do Apache
sudo systemctl status httpd
