#!/usr/bin/env bash
set -euo pipefail

# --- Read env from Vagrantfile ---
APP_USER="${APP_USER:-appuser}"
PROJECT_DIR="${PROJECT_DIR:-/home/${APP_USER}/pet-clinic}"
APP_DIR="${APP_DIR:-/home/${APP_USER}}"
DB_HOST="${DB_HOST:-192.168.56.10}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-dbname}"
DB_USER="${DB_USER:-dbuser}"
DB_PASS="${DB_PASS:-dbpass}"

echo "=== Creating non-root APP_USER: ${APP_USER} ==="
if ! id "${APP_USER}" &>/dev/null; then
  sudo useradd -m -s /bin/bash "${APP_USER}"
fi

echo "=== Installing Java JDK, git, and basic deps ==="
sudo apt-get update -y
sudo apt-get install -y openjdk-21-jdk git

echo "=== Cloning project to PROJECT_DIR: ${PROJECT_DIR} ==="
if [ ! -d "${PROJECT_DIR}" ]; then
  sudo -u "${APP_USER}" git clone \
    https://gitlab.com/kirillpavlov4u/pet-clinic.git \
    "${PROJECT_DIR}"
else
  echo "Project already exists, pulling latest changes..."
  sudo -u "${APP_USER}" bash -lc "cd '${PROJECT_DIR}' && git pull"
fi

echo "=== Building app with Maven wrapper (mvnw) ==="
# Project lives in forStep1/PetClinic
sudo -u "${APP_USER}" bash -lc "
  cd '${PROJECT_DIR}/forStep1/PetClinic' &&
  chmod +x mvnw &&
  ./mvnw clean package
"

echo '=== Copying JAR to APP_DIR (APP_USER home) ==='
TARGET_DIR="${PROJECT_DIR}/forStep1/PetClinic/target"
JAR_FILE=$(sudo -u "${APP_USER}" bash -lc "cd '${TARGET_DIR}' && ls *.jar | head -n 1")

if [ -z "${JAR_FILE}" ]; then
  echo "ERROR: No JAR found in ${TARGET_DIR}"
  exit 1
fi

sudo cp "${TARGET_DIR}/${JAR_FILE}" "${APP_DIR}/petclinic.jar"
sudo chown "${APP_USER}":"${APP_USER}" "${APP_DIR}/petclinic.jar"

echo "JAR copied to ${APP_DIR}/petclinic.jar"

echo "=== Setting DB_* environment variables in APP_VM ==="
# Create a profile script so variables are available for APP_USER logins
sudo tee /etc/profile.d/petclinic-env.sh >/dev/null <<EOF
export DB_HOST="${DB_HOST}"
export DB_PORT="${DB_PORT}"
export DB_NAME="${DB_NAME}"
export DB_USER="${DB_USER}"
export DB_PASS="${DB_PASS}"
EOF

sudo chmod +x /etc/profile.d/petclinic-env.sh

echo "=== Running PetClinic as APP_USER on port 8080 ==="
sudo -u "${APP_USER}" bash -lc "
  cd '${APP_DIR}' &&
  nohup java -jar petclinic.jar >petclinic.log 2>&1 &
"

echo "=== DONE ==="
echo "PetClinic should be available at: http://192.168.56.11:8080"