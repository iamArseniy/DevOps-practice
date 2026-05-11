# Базовый образ Python для запуска самописного web-приложения Flask.
FROM python:3.12-slim

# Устанавливаем Nginx и утилиты для проверки работы контейнера.
# Также удаляем стандартный сайт Nginx, чтобы он не перехватывал запросы
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx curl procps \
    && rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default \
    && rm -rf /var/lib/apt/lists/*

# Рабочая директория приложения.
WORKDIR /app

# Копируем зависимости Python.
COPY requirements.txt /app/requirements.txt

# Устанавливаем зависимости приложения.
RUN pip install --no-cache-dir -r /app/requirements.txt

# Копируем код web-приложения и стартовый скрипт.
COPY app.py /app/app.py
COPY start.sh /app/start.sh

# Даем право на запуск стартового скрипта.
RUN chmod +x /app/start.sh

# Nginx внутри контейнера будет слушать 80 порт.
EXPOSE 80

# Запускаем Flask-приложение и Nginx.
CMD ["/app/start.sh"]
