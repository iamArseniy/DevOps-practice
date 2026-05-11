# Docker Compose
## Что было сделано

Был создан `docker-compose.yml`, в котором описаны два сервиса:

- `web` — контейнер с Nginx и Flask-приложением;
- `new_db` — контейнер с PostgreSQL.

Также были настроены:

- bridge-сеть `10.10.10.0/28`;
- docker volume для хранения данных PostgreSQL;
- проброс порта `8080:80`;
- передача конфигурационных файлов через volume;
- очередность запуска сервисов через `depends_on`;
- доступ к базе данных по именам `new_db` и `dev_db`.

## Описание сервисов

### Web-сервис

Сервис `web` содержит:

- Nginx;
- самописное Flask-приложение.

Nginx принимает запросы на порту `80` внутри контейнера.

На хостовой машине сервис доступен по адресу:

```text
http://localhost:8080
```

---

### База данных

Сервис `new_db` использует PostgreSQL.

Данные базы сохраняются в docker volume:

```yaml
pg_data:
```

Это позволяет не терять данные при перезапуске контейнеров.

База данных доступна из контейнера `web` по двум именам:

```text
new_db
dev_db
```

---

## Docker-сеть

Для контейнеров создана отдельная bridge-сеть:

```text
10.10.10.0/28
```

Контейнеры находятся в одной сети и могут обращаться друг к другу по именам сервисов.

---

## Запуск

```bash
docker compose up -d --build
```

## Проверка

```bash
curl http://localhost:8080
curl http://localhost:8080/api/health
curl http://localhost:8080/api/db-check
```

## Проверка DNS-имен БД из web-контейнера

```bash
docker exec -it web_server getent hosts new_db
docker exec -it web_server getent hosts dev_db
```

## Проверка сети и volume

```bash
docker compose ps
docker network inspect lab5_lab_net
docker volume ls
```

## Остановка

```bash
docker compose down
```
