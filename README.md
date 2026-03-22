# Домашнее задание 1 — PostgreSQL Master/Replica + Когортный анализ

## Состав команды
- Тугов Евгений

## Что сделано
- [x] PostgreSQL master поднят в docker-compose
- [x] Инициализация трёх БД: `user_service_db`, `order_service_db`, `logistics_service_db`
- [x] Настроена async streaming-репликация (replication slot `replica_slot`)
- [x] FK constraints между таблицами внутри каждой БД
- [x] SCD Type 2 поля во всех основных таблицах
- [x] Business Keys через `*_external_id` (UUID) и `*_code` (VARCHAR)
- [x] Historical Data снапшоты в `order_items`
- [x] Когортный анализ (SQL-скрипт)
- [x] VIEW `v_cohort_analysis` для когортного анализа

## Структура БД

### user_service_db
- `users` — пользователи (SCD Type 2, BK: user_external_id)
- `user_addresses` — адреса пользователей (SCD Type 2, BK: address_external_id)
- `user_status_history` — история статусов пользователей

### order_service_db
- `orders` — заказы (SCD Type 2, BK: order_external_id)
- `products` — товары (SCD Type 2, BK: product_sku)
- `order_items` — позиции заказа (Historical Data snapshots)
- `order_status_history` — история статусов заказов

### logistics_service_db
- `warehouses` — склады (SCD Type 2, BK: warehouse_code)
- `pickup_points` — пункты выдачи (SCD Type 2, BK: pickup_point_code)
- `shipments` — отгрузки (SCD Type 2, BK: shipment_external_id)
- `shipment_movements` — движения отгрузок
- `shipment_status_history` — история статусов отгрузок

## Как запустить

### Требования
- Docker >= 20.10
- Docker Compose >= 2.0

### Запуск

```bash
git clone <your-repo-url>
cd hw1
docker-compose up -d
```

### Проверка

```bash
# Статус контейнеров
docker-compose ps

# Проверка репликации
docker exec -it pg-master psql -U postgres -c \
  "SELECT client_addr, state, sent_lsn, replay_lsn 
   FROM pg_stat_replication;"

# Проверка replication slot
docker exec -it pg-master psql -U postgres -c \
  "SELECT slot_name, slot_type, active 
   FROM pg_replication_slots;"

# Проверка WAL receiver на реплике
docker exec -it pg-replica psql -U postgres -c \
  "SELECT status, sender_host, written_lsn 
   FROM pg_stat_wal_receiver;"
```

### Когортный анализ

```bash
# Выполнить SQL-скрипт
docker cp sql/cohort_analysis.sql pg-master:/tmp/cohort_analysis.sql
docker exec -i pg-master psql -U postgres -d order_service_db \
  -f /tmp/cohort_analysis.sql

# Создать VIEW
docker cp sql/cohort_analysis_view.sql pg-master:/tmp/cohort_analysis_view.sql
docker exec -i pg-master psql -U postgres -d order_service_db \
  -f /tmp/cohort_analysis_view.sql

# Проверить VIEW
docker exec -it pg-master psql -U postgres -d order_service_db \
  -c "SELECT * FROM v_cohort_analysis;"
```

### Источники
https://www.postgresql.org/docs/15/warm-standby.html
https://www.postgresql.org/docs/15/app-pgbasebackup.html
https://docs.docker.com/reference/compose-file/services/#healthcheck

