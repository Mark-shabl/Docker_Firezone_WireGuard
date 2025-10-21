# 🚀 Развертывание Firezone

Инструкция по развертыванию Firezone на production-сервере.

## 📋 Требования

- **ОС**: Linux (Ubuntu 20.04+, CentOS 8+, Debian 11+)
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **RAM**: минимум 2GB, рекомендуется 4GB+
- **Диск**: минимум 10GB свободного места
- **Порты**: 80, 443, 8081 (должны быть открыты)

## 🛠 Установка

### 1. Установка Docker и Docker Compose

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-plugin

# CentOS/RHEL
sudo yum install -y docker docker-compose-plugin

# Запуск Docker
sudo systemctl start docker
sudo systemctl enable docker

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
```

### 2. Клонирование и настройка

```bash
# Клонируем репозиторий
git clone https://github.com/firezone/firezone.git
cd firezone

# Делаем скрипты исполняемыми
chmod +x generate-secrets.sh start-firezone.sh
```

### 3. Генерация секретов

```bash
# Генерируем .env файл с секретами
./generate-secrets.sh
```

**⚠️ ВАЖНО**: После генерации отредактируйте `.env` файл:
- Укажите пароль для email в `OUTBOUND_EMAIL_ADAPTER_OPTS`
- Проверьте все настройки

### 4. Настройка доменов

Убедитесь, что домены указывают на ваш сервер:
- `firezone.mark-sandbox.ru` → `95.165.74.49`
- `wireguard.mark-sandbox.ru` → `95.165.74.49`

## 🚀 Запуск

### Первый запуск

```bash
# Запускаем Firezone
./start-firezone.sh start
```

Этот скрипт:
1. Создаст необходимые Docker-тома
2. Запустит PostgreSQL и Vault
3. Выполнит миграции базы данных
4. Создаст администратора
5. Запустит все сервисы

### Управление сервисами

```bash
# Просмотр статуса
docker compose ps

# Просмотр логов
docker compose logs

# Логи конкретного сервиса
docker compose logs web

# Остановка
docker compose down

# Перезапуск
docker compose restart

# Запуск
docker compose up -d
```

## 🌐 Доступ к сервисам

После запуска будут доступны:

- **Веб-интерфейс**: https://firezone.mark-sandbox.ru
- **API**: https://wireguard.mark-sandbox.ru
- **Мониторинг**: http://localhost:4317 (OpenTelemetry)

## 👤 Первый вход

1. Откройте https://firezone.mark-sandbox.ru
2. Войдите с учетными данными:
   - **Email**: `firezone@localhost.local`
   - **Пароль**: `Firezone1234`

## 🔧 Настройка

### Создание Gateway токена

1. Войдите в веб-интерфейс
2. Перейдите в "Gateways" → "Add Gateway"
3. Скопируйте токен
4. Обновите `.env` файл:
   ```bash
   FIREZONE_GATEWAY_TOKEN=ваш_токен_здесь
   ```
5. Перезапустите: `./start-firezone.sh restart`

### Создание Client токена

1. В веб-интерфейсе создайте пользователя
2. Создайте устройство для пользователя
3. Скопируйте токен устройства
4. Обновите `.env` файл:
   ```bash
   FIREZONE_CLIENT_TOKEN=токен_устройства_здесь
   ```
5. Перезапустите: `./start-firezone.sh restart`

## 📊 Мониторинг

### Логи сервисов

```bash
# Все логи
docker compose logs

# Конкретный сервис
docker compose logs gateway
docker compose logs postgres

# Логи в реальном времени
docker compose logs -f
```

### Статус сервисов

```bash
docker compose ps
```

### OpenTelemetry

Мониторинг доступен на порту 4317:
- **Метрики**: http://localhost:4317/metrics
- **Трейсы**: http://localhost:4317/traces

## 🔒 Безопасность

### Настройка HTTPS

1. Получите SSL-сертификаты (Let's Encrypt)
2. Настройте reverse proxy (nginx/traefik)
3. Обновите домены в `.env`

### Firewall

```bash
# Открыть только необходимые порты
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8081/tcp
sudo ufw enable
```

## 🗄 Резервное копирование

### База данных

```bash
# Создание бэкапа
docker compose exec postgres pg_dump -U firezone firezone_prod > backup_$(date +%Y%m%d_%H%M%S).sql

# Восстановление
docker compose exec -T postgres psql -U firezone firezone_prod < backup_file.sql
```

### Конфигурация

```bash
# Бэкап конфигурации
tar -czf firezone_config_$(date +%Y%m%d_%H%M%S).tar.gz .env docker-compose.yml
```

## 🐛 Устранение неполадок

### Сервисы не запускаются

```bash
# Проверка логов
docker compose logs

# Проверка статуса
docker compose ps

# Перезапуск
docker compose restart
```

### Проблемы с базой данных

```bash
# Пересоздание БД
docker compose down
docker volume rm firezone_postgres_data
docker compose up -d
```

### Проблемы с сетью

```bash
# Проверка портов
sudo netstat -tlnp | grep -E ':(80|443|8081)'

# Проверка Docker сетей
docker network ls
```

## 📞 Поддержка

- **Документация**: https://www.firezone.dev/kb
- **Форум**: https://discourse.firez.one
- **Discord**: https://discord.gg/DY8gxpSgep
- **GitHub**: https://github.com/firezone/firezone

## 🔄 Обновление

```bash
# Остановка сервисов
docker compose down

# Обновление кода
git pull origin main

# Перезапуск
docker compose up -d
```

---

**✅ Готово!** Ваш Firezone VPN сервер запущен и готов к использованию!
