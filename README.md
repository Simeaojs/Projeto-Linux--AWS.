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
