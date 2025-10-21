# 🚀 Пошаговое руководство по развертыванию Firezone

## 📋 Подготовка сервера

### Шаг 1: Подключение к серверу
```bash
ssh root@95.165.74.49
# или
ssh your_user@95.165.74.49
```

### Шаг 2: Обновление системы
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### Шаг 3: Установка Docker и Docker Compose
```bash
# Ubuntu/Debian
sudo apt install -y docker.io docker-compose-plugin

# CentOS/RHEL
sudo yum install -y docker docker-compose-plugin

# Запуск Docker
sudo systemctl start docker
sudo systemctl enable docker

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
# Перелогиниться или выполнить:
newgrp docker
```

### Шаг 4: Проверка установки
```bash
docker --version
docker compose version
```

## 📥 Клонирование проекта

### Шаг 5: Клонирование репозитория
```bash
# Переходим в домашнюю директорию
cd ~

# Клонируем проект
git clone https://github.com/firezone/firezone.git
cd firezone

# Проверяем что файлы на месте
ls -la
```

### Шаг 6: Настройка прав доступа
```bash
# Делаем скрипт генерации секретов исполняемым
chmod +x generate-secrets.sh

# Проверяем права
ls -la generate-secrets.sh
```

## 🔐 Генерация секретов

### Шаг 7: Генерация .env файла
```bash
# Запускаем генерацию секретов
./generate-secrets.sh

# Проверяем что файл создался
ls -la .env
cat .env
```

### Шаг 8: Настройка email (ВАЖНО!)
```bash
# Открываем .env файл для редактирования
nano .env
# или
vim .env
```

**Найдите строку:**
```
OUTBOUND_EMAIL_ADAPTER_OPTS={"relay":"smtp.gmail.com","username":"sigudai.plez@gmail.com","password":"YOUR_EMAIL_PASSWORD","port":587,"tls"::always,"auth"::always}
```

**Замените `YOUR_EMAIL_PASSWORD` на реальный пароль от Gmail:**
```
OUTBOUND_EMAIL_ADAPTER_OPTS={"relay":"smtp.gmail.com","username":"sigudai.plez@gmail.com","password":"ваш_реальный_пароль","port":587,"tls"::always,"auth"::always}
```

**Сохраните файл** (в nano: Ctrl+X, Y, Enter)

## 🌐 Настройка доменов

### Шаг 9: Настройка DNS
Убедитесь, что домены указывают на ваш сервер:
- `firezone.mark-sandbox.ru` → `95.165.74.49`
- `wireguard.mark-sandbox.ru` → `95.165.74.49`

### Шаг 10: Настройка firewall
```bash
# Открываем необходимые порты
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 22/tcp  # SSH
sudo ufw enable

# Проверяем статус
sudo ufw status
```

## 🚀 Запуск Firezone

### Шаг 11: Первый запуск
```bash
# Запускаем базу данных и vault
docker compose up -d postgres vault

# Ждем готовности базы данных
sleep 10

# Выполняем миграции
docker compose run --rm elixir /bin/sh -c "cd apps/domain && mix ecto.create && mix ecto.migrate"

# Создаем администратора
docker compose run --rm elixir /bin/sh -c "cd apps/domain && mix ecto.seed"

# Запускаем все остальные сервисы
docker compose up -d
```

### Шаг 12: Проверка статуса
```bash
# Проверяем что все сервисы запустились
docker compose ps

# Смотрим логи (если есть проблемы)
docker compose logs
```

## 🔧 Настройка Gateway и Client

### Шаг 13: Получение Gateway токена
1. Откройте браузер: `https://firezone.mark-sandbox.ru`
2. Войдите с учетными данными:
   - **Email**: `firezone@localhost.local`
   - **Пароль**: `Firezone1234`
3. Перейдите в **"Gateways"** → **"Add Gateway"**
4. Скопируйте токен Gateway

### Шаг 14: Обновление Gateway токена
```bash
# Открываем .env файл
nano .env

# Находим строку:
FIREZONE_GATEWAY_TOKEN=

# Заменяем на:
FIREZONE_GATEWAY_TOKEN=ваш_токен_здесь

# Сохраняем файл
```

### Шаг 15: Перезапуск с Gateway токеном
```bash
# Перезапускаем сервисы
docker compose restart

# Проверяем статус
docker compose ps
```

### Шаг 16: Получение Client токена
1. В веб-интерфейсе создайте пользователя:
   - **Users** → **Add User**
2. Создайте устройство для пользователя:
   - **Devices** → **Add Device**
3. Скопируйте токен устройства

### Шаг 17: Обновление Client токена
```bash
# Открываем .env файл
nano .env

# Находим строку:
FIREZONE_CLIENT_TOKEN=

# Заменяем на:
FIREZONE_CLIENT_TOKEN=токен_устройства_здесь

# Сохраняем файл
```

### Шаг 18: Финальный перезапуск
```bash
# Перезапускаем с Client токеном
docker compose restart

# Проверяем что все работает
docker compose ps
```

## ✅ Проверка работоспособности

### Шаг 19: Тестирование веб-интерфейса
```bash
# Проверяем доступность
curl -I https://firezone.mark-sandbox.ru
curl -I https://wireguard.mark-sandbox.ru
```

### Шаг 20: Тестирование VPN-подключения
```bash
# Проверяем что тестовый клиент подключился
docker compose logs client

# Должны увидеть что-то вроде:
# "Connected to gateway"
# "Tunnel established"
```

### Шаг 21: Тестирование ресурсов
```bash
# Проверяем доступность тестовых ресурсов
curl http://172.20.0.100  # httpbin
curl http://172.20.0.110  # iperf3
```

## 📊 Мониторинг

### Шаг 22: Просмотр логов
```bash
# Все логи
docker compose logs

# Логи конкретного сервиса
docker compose logs web
docker compose logs gateway
docker compose logs postgres

# Логи в реальном времени
docker compose logs -f
```

### Шаг 23: Мониторинг ресурсов
```bash
# Использование диска
df -h

# Использование памяти
free -h

# Статус Docker
docker system df
```

## 🔄 Обновление проекта

### Шаг 24: Обновление через Git
```bash
# Останавливаем сервисы
docker compose down

# Обновляем код
git pull origin main

# Перезапускаем
docker compose up -d
```

## 🗄 Резервное копирование

### Шаг 25: Создание бэкапа
```bash
# Бэкап базы данных
docker compose exec postgres pg_dump -U firezone firezone_prod > backup_$(date +%Y%m%d_%H%M%S).sql

# Бэкап конфигурации
tar -czf firezone_config_$(date +%Y%m%d_%H%M%S).tar.gz .env docker-compose.yml

# Проверяем бэкапы
ls -la backup_* firezone_config_*
```

## 🐛 Устранение неполадок

### Если сервисы не запускаются:
```bash
# Проверяем логи
docker compose logs

# Перезапускаем
docker compose restart

# Если не помогает - полный перезапуск
docker compose down
docker system prune -f
docker compose up -d
```

### Если проблемы с базой данных:
```bash
# Пересоздание БД
docker compose down
docker volume rm firezone_postgres_data
docker compose up -d
```

### Если проблемы с сетью:
```bash
# Проверка портов
sudo netstat -tlnp | grep -E ':(80|443|8081)'

# Проверка Docker сетей
docker network ls
```

## 📞 Поддержка

Если что-то не работает:
1. Проверьте логи: `docker compose logs`
2. Проверьте статус: `docker compose ps`
3. Проверьте документацию: `README-FIREZONE-DEPLOYMENT.md`

---

## 🎉 Готово!

После выполнения всех шагов у вас будет работающий Firezone VPN сервер:
- **Веб-интерфейс**: https://firezone.mark-sandbox.ru
- **API**: https://wireguard.mark-sandbox.ru
- **Мониторинг**: http://95.165.74.49:4317

**Удачного развертывания!** 🚀
