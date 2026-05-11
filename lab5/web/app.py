import os
from pathlib import Path

import psycopg2
from flask import Flask, jsonify


def load_env_file(path: str) -> None:
    """Простая загрузка KEY=VALUE из конфигурационного файла."""
    env_path = Path(path)
    if not env_path.exists():
        return

    for line in env_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip())


load_env_file("/app/config/app.env")

app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(
        status="ok",
        message="Nginx reverse proxy + Flask app are running",
        endpoints=["/api/health", "/api/db-check"],
    )


@app.get("/api/health")
def health():
    return jsonify(
        status="UP",
        app=os.getenv("APP_NAME", "demo-web-app"),
    )


@app.get("/api/db-check")
def db_check():
    connection = psycopg2.connect(
        host=os.getenv("DB_HOST", "new_db"),
        port=int(os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("DB_NAME", "appdb"),
        user=os.getenv("DB_USER", "appuser"),
        password=os.getenv("DB_PASSWORD", "app_password"),
    )

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT current_database(), current_user, version();")
            database, user, version = cursor.fetchone()
        return jsonify(
            status="DB_CONNECTION_OK",
            db_host=os.getenv("DB_HOST", "new_db"),
            database=database,
            user=user,
            version=version,
        )
    finally:
        connection.close()


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
