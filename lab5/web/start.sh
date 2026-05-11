#!/bin/sh
set -e

# Проверяем, что конфигурация Nginx корректная.
nginx -t

# Запускаем самописное Flask-приложение на localhost:5000 внутри web-контейнера.
python /app/app.py &

# Запускаем Nginx в foreground-режиме, чтобы контейнер не завершался.
exec nginx -g 'daemon off;'
