#!/bin/bash
set -e

if [[ -z "$SSH_KEY" || -z "$EC2_USER" || -z "$EC2_IP" || -z "$REMOTE_PATH" || -z "$REPO_URL" || -z "$APP_NAME" || -z "$NODE_ENV" || -z "$GIT_BRANCH" ]]; then
  echo "Faltan variables de entorno necesarias."
  exit 1
fi

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "
  if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo 'Node.js o npm no están instalados. Instalando...'
    sudo apt update
    sudo apt upgrade -y
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install nodejs -y
  fi

  if ! command -v pm2 >/dev/null 2>&1; then
    sudo npm install -g pm2
  fi

  if [ ! -d \"$REMOTE_PATH\" ]; then
    mkdir -p $REMOTE_PATH
    cd $REMOTE_PATH
    git clone $REPO_URL .
    git checkout $GIT_BRANCH
  else
    cd $REMOTE_PATH
    git fetch
    git checkout $GIT_BRANCH
    git pull
  fi

  npm ci
  echo \"NODE_ENV=$NODE_ENV\" > .env
  echo \"PORT=3000\" >> .env
  pm2 restart $APP_NAME || pm2 start server.js --name $APP_NAME
"
