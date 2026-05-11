# Базовый образ Debian 12.
FROM debian:12-slim

# Автор образа.
MAINTAINER Baranov A.V.

# Переменные окружения для автоматической установки пакетов и настройки PostgreSQL.
ENV DEBIAN_FRONTEND=noninteractive
ENV POSTGRES_USER=appuser
ENV POSTGRES_PASSWORD=app_password
ENV POSTGRES_DB=appdb
ENV PGDATA=/var/lib/postgresql/data

# Рабочая директория внутри контейнера.
WORKDIR /opt/app

# Устанавливаем веб-сервер Nginx и базу данных PostgreSQL.
# После установки очищаем apt-кэш, чтобы уменьшить размер итогового image.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        postgresql \
        postgresql-contrib \
        ca-certificates \
        bash && \
    rm -rf /var/lib/apt/lists/*

# Создаем нужные директории и выставляем владельцев для Nginx и PostgreSQL.
RUN mkdir -p /opt/app /var/run/postgresql /var/lib/postgresql/data /run/nginx && \
    chown -R postgres:postgres /var/run/postgresql /var/lib/postgresql && \
    chown -R www-data:www-data /var/www/html /run/nginx

# Копируем главную HTML-страницу для Nginx.
COPY ./html/index.html /var/www/html/index.html

# Копируем конфигурацию виртуального хоста Nginx.
COPY ./nginx/default.conf /etc/nginx/sites-available/default

# Копируем скрипт запуска, который стартует PostgreSQL и Nginx.
COPY ./scripts/start.sh /usr/local/bin/start.sh


# Добавляем информационный файл.
ADD ./assets/info.txt /opt/app/info.txt

# Даем скрипту запуска права на выполнение.
RUN chmod +x /usr/local/bin/start.sh

# Объявляем volume для хранения данных PostgreSQL вне writable-слоя контейнера.
VOLUME ["/var/lib/postgresql/data"]

# Открываем порты: 80 для Nginx и 5432 для PostgreSQL.
EXPOSE 80 5432

# Запуск будет выполняться от root, так как внутри стартуют два сервиса.
# PostgreSQL в start.sh запускается отдельно от пользователя postgres.
USER root

# Основная команда контейнера: запуск PostgreSQL и Nginx.
CMD ["/usr/local/bin/start.sh"]
