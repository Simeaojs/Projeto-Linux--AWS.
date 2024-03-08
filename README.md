# Atividade Linux - AWS 🐧☁️

## Descrição 

A tarefa envolverá a criação de uma chave pública para acesso, o provisionamento de uma instância EC2 utilizando o sistema operacional Amazon Linux 2, a alocação de um endereço IP elástico que será associado à instância EC2, a abertura de portas de comunicação para permitir acesso público, a configuração do sistema de arquivos NFS, a criação de um diretório correspondente ao nome do usuário no filesystem do NFS, a instalação e configuração do servidor Apache, a elaboração de um script para verificar a disponibilidade do serviço e enviar os resultados para o diretório NFS, e a configuração da execução automatizada do script a cada intervalo de 5 minutos.

_ _ _

## Detalhes da Configuração.

### Instancia AWS:
- Chave pública para acesso ao ambiente
- Amazon Linux 2
    - t3.small
    - 16 GB SSD
- 1 Elastic IP associado a instancia
- Portas de comunicação liberadas
    - 22/TCP (SSH)
    - 111/TCP e UDP (RPC)
    - 2049/TCP/UDP (NFS)
    - 80/TCP (HTTP)
    - 443/TCP (HTTPS)

### Configurações Linux:

- Configurar o NFS entregue;
- Criar um diretorio dentro do filesystem do NFS com seu nome;
- Subir um apache no servidor - o apache deve estar online e rodando;
- Criar um script que valide se o serviço esta online e envie o resultado da validação para o seu diretorio no nfs;
    - O script deve conter - Data HORA + nome do serviço + Status + mensagem personalizada de ONLINE ou offline;
    - O script deve gerar 2 arquivos de saida: 1 para o serviço online e 1 para o serviço OFFLINE;
    - Execução automatizada do script a cada 5 minutos.

---

## Guia Detalhado para Configuração.

### Geração de chave pública de acesso e anexá-la à uma nova instância EC2 na AWS.
- Acessar a AWS na pagina do serviço EC2, e clicar em "Pares de chaves" no menu lateral esquerdo.
- Clicar em "Criar par de chaves".
- Inserir um nome para a chave e clicar em "Criar par de chaves".
- Salvar o arquivo .pem gerado em um local seguro.
- Clicar em "Instâncias" no menu lateral esquerdo.
- Clicar em "Executar instâncias".
- Configurar as Tags da instância (Name, Project e CostCenter) para instâncias e volumes.
- Selecionar a imagem Amazon Linux 2 AMI (HVM), SSD Volume Type.
- Selecionar o tipo de instância t3.small.
- Selecionar a chave gerada anteriormente.
- Colocar 16 GB de armazenamento gp2 (SSD).
- Clicar em "Executar instância".

**Referência**: [Documentação Amazon ec2](https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/EC2_GetStarted.html) 

## Alocar um endereço IP elástico à instância EC2.

- Acessar a AWS na pagina do serviço EC2, e clicar em "IPs elásticos" no menu lateral esquerdo.
- Clicar em "Alocar endereço IP elástico".
- Selecionar o ip alocado e clicar em "Ações" > "Associar endereço IP elástico".
- Selecionar a instância EC2 criada anteriormente e clicar em "Associar".


## Configurando regras de segurança.
Acessar a AWS na pagina do serviço EC2, e clicar em "Segurança" > "Grupos de segurança" no menu lateral esquerdo.
- Selecionar o grupo de segurança da instância EC2 criada anteriormente.
- Clicar em "Editar regras de entrada".
- Configurar as seguintes regras:

    Tipo | Protocolo | Intervalo de portas | Origem | Descrição
    ---|---|---|---|---
    SSH | TCP | 22 | MEU IP | SSH
    TCP personalizado | TCP | 80 | 0.0.0.0/0 | HTTP
    TCP personalizado | TCP | 443 | 0.0.0.0/0 | HTTPS
    TCP personalizado | TCP | 111 | 0.0.0.0/0 | RPC
    UDP personalizado | UDP | 111 | 0.0.0.0/0 | RPC
    TCP personalizado | TCP | 2049 | 0.0.0.0/0 | NFS
    UDP personalizado | UDP | 2049 | 0.0.0.0/0 | NFS


 ## Configurando o Sistema de Arquivos AWS EFS na Instância EC2.

- Acesse o Console da AWS.
- Navegue até o Serviço EFS.
- Crie um Sistema de Arquivos EFS.
- Configure as Opções:
  - Escolha a VPC (deve ser a mesma VPC da Instância EC2).
- Defina as opções de segurança de acesso, liberando a porta 2049/TCP
- Crie o Ponto de Montagem na Instância EC2:
  - Vá para a instância EC2.
  - Instale o pacote ` sudo yum install -y amazon-efs-utils ` para suporte NFS.
  - Crie um diretório local que servirá como ponto de montagem.
- Obtenha as Informações de Montagem do EFS:
  - Volte ao console do EFS e obtenha as informações de DNS do ponto de montagem.
- Monte o Sistema de Arquivos na Instância EC2:
  - Execute o comando de montagem na instância EC2 usando o cliente do NFS:

  
   ``` sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 <DNS do EFS>:/ /<caminho local> ```

- Configure a Montagem Automática:
  - Abra o arquivo `/etc/fstab` em um editor.
  - Para montar automaticamente um sistema de arquivos usando o NFS em vez do auxiliar de montagem do EFS, adicione a seguinte linha ao `/etc/fstab` arquivo.

   ```file_system_id.efs.aws-region.amazonaws.com:/ mount_point nfs4 nfsvers=4.1,rsize=1048576wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0 ``` 

- Substitua `file_system_id` pelo ID do sistema de arquivos que você está montando.
  - Substitua `aws-region` Região da AWS pela que está no sistema de arquivos, como. us-east-1
  - Substitua `mount_point` pelo ponto de montagem do sistema de arquivos.

- Confirme se o sistema de arquivos EFS está montado corretamente usando o comando `df -h`.

**Referência**: [Documentação do Amazon EFS](https://docs.aws.amazon.com/pt_br/efs/latest/ug/whatisefs.html) 

## Configurar o Apache.

- Executar o comando `sudo yum update -y` para atualizar o sistema.
- Executar o comando `sudo yum install httpd -y` para instalar o apache.
- Executar o comando `sudo systemctl start httpd` para iniciar o apache.
- Executar o comando `sudo systemctl enable httpd` para habilitar o apache para iniciar automaticamente.
- Executar o comando `sudo systemctl status httpd` para verificar o status do apache.
- Configurações adicionais do apache podem ser feitas no arquivo `/etc/httpd/conf/httpd.conf`.
- Parar o apache, executar o comando `sudo systemctl stop httpd`.

### Exemplo de user data para instalação do apache na criação da ec2.
<details>
<summary>Script Apache.</summary>

```bash

#!/bin/bash

sudo yum update -y

sudo yum install httpd -y

sudo systemctl start httpd

sudo systemctl enable httpd

sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Criar um arquivo index.html de exemplo (opcional)
echo "<html><body><h1>Meu Site Apache</h1></body></html>" | sudo tee /var/www/html/index.html

sudo systemctl restart httpd

sudo systemctl status httpd
``` 

</details>

___

## Configurar o script de validação.

- Abra um editor de texto no seu servidor e crie um script Bash usando o comando `nano check_service.sh`.
- Adicione o seguinte conteúdo ao script. 
```bash

#!/bin/bash

SERVICE_NAME="httpd"
EFS_MOUNT_PATH="example/etc"

CURRENT_DATE=$(date "+%Y-%m-%d")
CURRENT_TIME=$(date "+%H:%M:%S")

if systemctl is-active --quiet $SERVICE_NAME; then
    STATUS="ONLINE"
    MESSAGE="O serviço $SERVICE_NAME está online."
    OUTPUT_FILE="$EFS_MOUNT_PATH/status_online.txt"
else
    STATUS="OFFLINE"
    MESSAGE="O serviço $SERVICE_NAME está offline."
    OUTPUT_FILE="$EFS_MOUNT_PATH/status_offline.txt"
fi

RESULT_STRING="$CURRENT_DATE $CURRENT_TIME"
RESULT_STRING+="\nServiço: $SERVICE_NAME"
RESULT_STRING+="\nStatus: $STATUS"
RESULT_STRING+="\nMensagem: $MESSAGE"

echo -e "$RESULT_STRING\n" >> "$OUTPUT_FILE"

``` 

- Salve o arquivo de script.
- Execute o comando `chmod +x nome_do_script` para tornar o arquivo de script executável.
- Execute o comando `./nome_do_script` para executar o script.

## Agendamento de Execução automatizada do Script a cada 5 minutos.

- Execute o comando `crontab -e` para editar o cronjob.
- Adicione a seguinte linha de código no arquivo de cronjob:

``` */5 * * * * /caminho/do/script/check_service.sh ``` 

- Salve o arquivo de cronjob.

_ _ _ 

## 🌱Contribuição

Contribuições são bem-vindas! Se você identificar problemas ou melhorias, sinta-se à vontade para abrir um pull request.

<p align="center">
  <img src="https://s3.amazonaws.com/imagemcompas.oul/compass.png" alt="">
</p>

