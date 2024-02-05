#!/bin/bash

SERVICE_NAME="httpd"  
EFS_MOUNT_PATH="example/nfs"  

# Obter a data e a hora atual
CURRENT_DATE=$(date "+%Y-%m-%d")
CURRENT_TIME=$(date "+%H:%M:%S")

# Verifica se o serviço está em execução
if systemctl is-active --quiet $SERVICE_NAME; then
    STATUS="ONLINE"
    MESSAGE="O serviço $SERVICE_NAME está online."
else
    STATUS="OFFLINE"
    MESSAGE="O serviço $SERVICE_NAME esta offline."
fi

# Construir a string completa com data, hora, nome do serviço, status e mensagem
RESULT_STRING="$CURRENT_DATE $CURRENT_TIME"
RESULT_STRING+="\nServiço: $SERVICE_NAME"
RESULT_STRING+="\nStatus: $STATUS"
RESULT_STRING+="\nMensagem: $MESSAGE"


echo -e "$RESULT_STRING\n" >> "$EFS_MOUNT_PATH/status.txt"