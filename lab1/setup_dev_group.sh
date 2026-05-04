#!/usr/bin/env bash

set -euo pipefail

LOG_FILE="/var/log/setup_dev_group_$(date +%Y-%m-%d_%H-%M-%S).log"
BASE_DIR=""

usage() {
    echo "Usage: sudo $0 -d <base_directory>"
    echo "Example: sudo $0 -d /opt/workdirs"
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

if [[ "$EUID" -ne 0 ]]; then
    echo "Ошибка: скрипт нужно запускать через sudo или от root"
    exit 1
fi

touch "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

log "Старт выполнения скрипта"
log "Лог-файл: $LOG_FILE"

while getopts ":d:h" opt; do
    case "$opt" in
        d)
            BASE_DIR="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        :)
            log "Ошибка: ключ -$OPTARG требует значение"
            usage
            exit 1
            ;;
        \?)
            log "Ошибка: неизвестный ключ -$OPTARG"
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$BASE_DIR" ]]; then
    read -rp "Введите путь для создания рабочих директорий: " BASE_DIR
fi

if [[ -z "$BASE_DIR" ]]; then
    log "Ошибка: путь директории не может быть пустым"
    exit 1
fi

log "Базовая директория: $BASE_DIR"

if ! command -v setfacl >/dev/null 2>&1; then
    log "Ошибка: команда setfacl не найдена"
    log "Установите пакет acl:"
    log "Ubuntu/Debian: sudo apt install acl"
    log "CentOS/RHEL: sudo yum install acl"
    exit 1
fi

mkdir -p "$BASE_DIR"
log "Базовая директория создана или уже существует"

if getent group dev >/dev/null; then
    log "Группа dev уже существует"
else
    groupadd dev
    log "Группа dev создана"
fi

SUDOERS_FILE="/etc/sudoers.d/dev-nopasswd"

echo "%dev ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"

if visudo -cf "$SUDOERS_FILE"; then
    log "Права sudo без пароля для группы dev настроены"
else
    log "Ошибка в sudoers-файле"
    rm -f "$SUDOERS_FILE"
    exit 1
fi

mapfile -t USERS < <(
    awk -F: '
    $3 >= 1000 && $3 < 65534 && $7 !~ /(nologin|false)$/ {
        print $1
    }' /etc/passwd
)

if [[ "${#USERS[@]}" -eq 0 ]]; then
    log "Не системные пользователи не найдены"
    exit 0
fi

log "Найдены не системные пользователи: ${USERS[*]}"

for USERNAME in "${USERS[@]}"; do
    log "Обработка пользователя: $USERNAME"

    usermod -aG dev "$USERNAME"
    log "Пользователь $USERNAME добавлен в группу dev"
    PRIMARY_GROUP="$(id -gn "$USERNAME")"

    WORKDIR="${BASE_DIR}/${USERNAME}_workdir"
    mkdir -p "$WORKDIR"

    chown "$USERNAME:$PRIMARY_GROUP" "$WORKDIR"

    chmod 660 "$WORKDIR"

    setfacl -m g:dev:r-- "$WORKDIR"

    log "Создана директория: $WORKDIR"
    log "Владелец: $USERNAME"
    log "Группа: $PRIMARY_GROUP"
    log "Права: 660"
    log "ACL: группе dev добавлено право чтения"
done

log "Скрипт успешно завершен"