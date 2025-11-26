#!/usr/bin/env bash

# Read values from environment (provided by Vagrant)
DB_USER="${DB_USER:-dbuser}"
DB_PASS="${DB_PASS:-dbpass}"
DB_NAME="${DB_NAME:-dbname}"
DB_SUBNET="${DB_SUBNET:-192.168.56.%}"
DB_PRIVATE_IP="${DB_PRIVATE_IP:-192.168.56.10}"

echo "=== Installing MySQL server ==="
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

echo "=== Configuring MySQL to listen only on private IP: ${DB_PRIVATE_IP} ==="

# On Ubuntu/Debian, main mysqld config usually here:
MYSQL_CNF="/etc/mysql/mysql.conf.d/mysqld.cnf"

# Backup original file once
if [ ! -f "${MYSQL_CNF}.orig" ]; then
  sudo cp "${MYSQL_CNF}" "${MYSQL_CNF}.orig"
fi

# Change bind-address to the private IP
if grep -q "^bind-address" "${MYSQL_CNF}"; then
  sudo sed -i "s/^bind-address.*/bind-address = ${DB_PRIVATE_IP}/" "${MYSQL_CNF}"
else
  echo "bind-address = ${DB_PRIVATE_IP}" | sudo tee -a "${MYSQL_CNF}" > /dev/null
fi

sudo systemctl restart mysql

echo "=== Creating database and user ==="
# Use root over unix socket (default on fresh Ubuntu MySQL)
sudo mysql <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

-- Create user limited to the private subnet
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_SUBNET}' IDENTIFIED BY '${DB_PASS}';

GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${DB_SUBNET}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "=== MySQL setup done ==="
echo "DB_NAME = ${DB_NAME}"
echo "DB_USER = ${DB_USER}"
echo "DB_PASS = ${DB_PASS}"
echo "Allowed hosts = ${DB_SUBNET}"