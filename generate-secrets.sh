#!/bin/bash

# Скрипт для генерации секретов для Firezone
# Запускать перед первым запуском docker-compose

echo "🔐 Генерация секретов для Firezone..."

# Проверяем наличие openssl
if ! command -v openssl &> /dev/null; then
    echo "❌ Ошибка: openssl не установлен. Установите его:"
    echo "   Ubuntu/Debian: sudo apt-get install openssl"
    echo "   CentOS/RHEL: sudo yum install openssl"
    exit 1
fi

# Создаем .env файл если его нет
if [ ! -f .env ]; then
    echo "📝 Создание файла .env..."
    touch .env
fi

# Генерируем секреты
SECRET_KEY_BASE=$(openssl rand -base64 64 | tr -d '\n')
TOKENS_KEY_BASE=$(openssl rand -base64 64 | tr -d '\n')
TOKENS_SALT=$(openssl rand -base64 32 | tr -d '\n')
LIVE_VIEW_SIGNING_SALT=$(openssl rand -base64 32 | tr -d '\n')
COOKIE_SIGNING_SALT=$(openssl rand -base64 32 | tr -d '\n')
COOKIE_ENCRYPTION_SALT=$(openssl rand -base64 32 | tr -d '\n')
RELEASE_COOKIE=$(openssl rand -base64 32 | tr -d '\n')
DATABASE_PASSWORD=$(openssl rand -base64 32 | tr -d '\n')
VAULT_DEV_ROOT_TOKEN_ID=$(openssl rand -base64 32 | tr -d '\n')

# Генерируем ID для компонентов
FIREZONE_GATEWAY_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
FIREZONE_CLIENT_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')

# Записываем в .env файл
cat > .env << EOF
# Firezone Production Configuration
# Сгенерировано: $(date)

# Домены
WEB_EXTERNAL_URL=https://firezone.mark-sandbox.ru/
API_EXTERNAL_URL=https://wireguard.mark-sandbox.ru/

# База данных
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_NAME=firezone_prod
DATABASE_USER=firezone
DATABASE_PASSWORD=${DATABASE_PASSWORD}

# Секреты (сгенерированы автоматически)
SECRET_KEY_BASE=${SECRET_KEY_BASE}
TOKENS_KEY_BASE=${TOKENS_KEY_BASE}
TOKENS_SALT=${TOKENS_SALT}
LIVE_VIEW_SIGNING_SALT=${LIVE_VIEW_SIGNING_SALT}
COOKIE_SIGNING_SALT=${COOKIE_SIGNING_SALT}
COOKIE_ENCRYPTION_SALT=${COOKIE_ENCRYPTION_SALT}
RELEASE_COOKIE=${RELEASE_COOKIE}

# Vault
VAULT_DEV_ROOT_TOKEN_ID=${VAULT_DEV_ROOT_TOKEN_ID}

# VPN настройки
FIREZONE_VPN_CIDR=10.3.0.0/16

# ID компонентов
FIREZONE_GATEWAY_ID=${FIREZONE_GATEWAY_ID}
FIREZONE_CLIENT_ID=${FIREZONE_CLIENT_ID}

# Токены (будут созданы после первого запуска)
FIREZONE_GATEWAY_TOKEN=
FIREZONE_CLIENT_TOKEN=

# Аутентификация (только email)
AUTH_PROVIDER_ADAPTERS=email

# Email настройки
OUTBOUND_EMAIL_FROM=sigudai.plez@gmail.com
OUTBOUND_EMAIL_ADAPTER=Elixir.Swoosh.Adapters.SMTP
OUTBOUND_EMAIL_ADAPTER_OPTS={"relay":"smtp.gmail.com","username":"sigudai.plez@gmail.com","password":"YOUR_EMAIL_PASSWORD","port":587,"tls"::always,"auth"::always}

# Логирование
LOG_LEVEL=info
RUST_LOG=info

# Мониторинг
OTEL_ENABLED=true
OTEL_GRPC_ENDPOINT=otel:4317

# Флаги функций
FEATURE_POLICY_CONDITIONS_ENABLED=true
FEATURE_MULTI_SITE_RESOURCES_ENABLED=true
FEATURE_SELF_HOSTED_RELAYS_ENABLED=true
FEATURE_REST_API_ENABLED=true
FEATURE_INTERNET_RESOURCE_ENABLED=true

# Erlang кластер
ERLANG_DISTRIBUTION_PORT=9000

# Phoenix настройки
PHOENIX_HTTP_WEB_PORT=8080
PHOENIX_HTTP_API_PORT=8081
PHOENIX_SECURE_COOKIES=true

# Миграции
RUN_MANUAL_MIGRATIONS=true
STATIC_SEEDS=false
EOF

echo "✅ Секреты сгенерированы и сохранены в .env"
echo ""
echo "⚠️  ВАЖНО: Отредактируйте .env файл и укажите:"
echo "   1. Пароль для email (OUTBOUND_EMAIL_ADAPTER_OPTS)"
echo "   2. Проверьте все настройки"
echo ""
echo "📋 Следующие шаги:"
echo "   1. Отредактируйте .env файл (пароль email)"
echo "   2. Запустите: docker compose up -d postgres vault"
echo "   3. Выполните миграции: docker compose run --rm elixir /bin/sh -c 'cd apps/domain && mix ecto.create && mix ecto.migrate'"
echo "   4. Создайте админа: docker compose run --rm elixir /bin/sh -c 'cd apps/domain && mix ecto.seed'"
echo "   5. Запустите все сервисы: docker compose up -d"
