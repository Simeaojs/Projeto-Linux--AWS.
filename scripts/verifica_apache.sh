#!/bin/bash

# Definição do nome do serviço e do diretório de montagem do EFS
SERVICE_NAME="httpd"
EFS_MOUNT_PATH="example/etc"

# Obtenção da data e hora atuais
CURRENT_DATE=$(date "+%Y-%m-%d")
CURRENT_TIME=$(date "+%H:%M:%S")

# Verificação do status do serviço
if systemctl is-active --quiet $SERVICE_NAME; then
    STATUS="ONLINE"
    MESSAGE="O serviço $SERVICE_NAME está online."
    OUTPUT_FILE="$EFS_MOUNT_PATH/status_online.txt"
else
    STATUS="OFFLINE"
    MESSAGE="O serviço $SERVICE_NAME está offline."
    OUTPUT_FILE="$EFS_MOUNT_PATH/status_offline.txt"
fi

# Construção da string completa com data, hora, nome do serviço, status e mensagem
RESULT_STRING="$CURRENT_DATE $CURRENT_TIME"
RESULT_STRING+="\nServiço: $SERVICE_NAME"
RESULT_STRING+="\nStatus: $STATUS"
RESULT_STRING+="\nMensagem: $MESSAGE"

# Escrita da string no arquivo correspondente
echo -e "$RESULT_STRING\n" >> "$OUTPUT_FILE"
