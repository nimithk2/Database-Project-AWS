#!/bin/bash
build_frontend=0

while getopts ":b" option; do
  case $option in
    b)
      build_frontend=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Prompt for database details with default values
# shellcheck disable=SC2162
read -p "Enter database host (default: 172.31.46.76): " db_host
db_host=${db_host:-172.31.46.76}

read -p "Enter database user (default: root): " db_user
db_user=${db_user:-root}

read -sp "Enter database password: " db_password
db_password=${db_password:-@a7875747A}
echo

read -p "Enter database name: " db_name
db_name=${db_name:-team10}

export DB_HOST=$db_host
export DB_USER=$db_user
export DB_PASSWORD=$db_password
export DB_NAME=$db_name

cd backend
npm install

PORT=3000
PID=$(lsof -i :$PORT -t)

if [ ! -z "$PID" ]; then
    echo "Port $PORT is in use by PID $PID. Attempting to terminate..."
    kill -9 $PID
fi

echo "Starting Node.js application..."

node app.js &

if [ "$build_frontend" -eq 1 ]; then
    cd ../frontend
    npm install
    npm run build
fi

sudo systemctl stop nginx
sudo systemctl start nginx
