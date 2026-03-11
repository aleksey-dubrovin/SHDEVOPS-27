# Стадия сборки
FROM python:3.9-slim as builder

WORKDIR /app

# Копирование зависимостей
COPY requirements.txt .

# Установка зависимостей
RUN pip install --user -r requirements.txt

# Финальная стадия
FROM python:3.9-slim

WORKDIR /app

# Копирование установленных пакетов из стадии сборки
COPY --from=builder /root/.local /root/.local

# Копирование кода приложения
COPY . .

# Обновление PATH для использования установленных пакетов
ENV PATH=/root/.local/bin:$PATH

# Открытие порта
EXPOSE 5000

# Запуск приложения
CMD ["python", "main.py"]