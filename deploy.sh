#!/bin/bash

# Script de déploiement pour l'application MyBank
# Assurez-vous d'avoir Docker installé sur votre machine
# et d'avoir accès à la clé privée pour le déploiement.
# Remplacez le chemin de la clé privée par le vôtre
# Exemple : C:\Users\<your_profile>\<keyfile>.pem
# C:\Users\rejen\OneDrive\Documents\rejentest_key.pem

# Connexion à la VM Azure et exécution du script de déploiement
# Remplacez l'adresse IP par celle de votre VM Azure

# Stop the script on any error
set -e

# Variables
IMAGE_NAME="fredericeducentre/matrix"
CONTAINER_NAME="matrix_container"
PORT=80  # ou un autre port si besoin
REMOTE_PORT=1234  # port exposé sur la VM

echo "🧠 [1/6] Mise à jour des paquets..."
sudo apt update
sudo apt install -y curl

echo "🐳 [2/6] Installation de Docker si nécessaire..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "📝 Redémarre ta session ou exécute 'newgrp docker' pour activer Docker sans sudo."
fi

echo "📦 [3/6] Téléchargement de l'image Docker: $IMAGE_NAME..."
sudo docker pull $IMAGE_NAME

echo "🧼 [4/6] Suppression de l'ancien conteneur s'il existe..."
sudo docker rm -f $CONTAINER_NAME 2>/dev/null || true

echo "🚀 [5/6] Lancement du conteneur Docker..."
sudo docker run -d --name $CONTAINER_NAME -p $REMOTE_PORT:$PORT $IMAGE_NAME

echo "✅ [6/6] Déploiement terminé !"
echo "🌐 Accédez à l'application : http://$(curl -s ifconfig.me):$REMOTE_PORT"
