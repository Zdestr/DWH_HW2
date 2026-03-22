CREATE DATABASE order_service_db;

\connect order_service_db

CREATE TABLE products (
    product_id           SERIAL   PRIMARY KEY,
    product_sku          VARCHAR  UNIQUE NOT NULL,
    product_name         VARCHAR,
    category             VARCHAR,
    brand                VARCHAR,
    price                DECIMAL,
    currency             VARCHAR,
    weight_grams         INTEGER,
    dimensions_length_cm DECIMAL,
    dimensions_width_cm  DECIMAL,
    dimensions_height_cm DECIMAL,
    is_active            BOOLEAN,
    effective_from       TIMESTAMP,
    effective_to         TIMESTAMP,
    is_current           BOOLEAN,
    created_at           TIMESTAMP,
    updated_at           TIMESTAMP,
    created_by           VARCHAR,
    updated_by           VARCHAR
);

CREATE TABLE orders (
    order_id                     SERIAL    PRIMARY KEY,
    order_external_id            UUID      UNIQUE NOT NULL,
    user_external_id             UUID      NOT NULL,
    order_number                 VARCHAR,
    order_date                   DATE,
    status                       VARCHAR,
    subtotal                     DECIMAL,
    tax_amount                   DECIMAL,
    shipping_cost                DECIMAL,
    discount_amount              DECIMAL,
    currency                     VARCHAR,
    delivery_address_external_id UUID,
    delivery_type                VARCHAR,
    expected_delivery_date       DATE,
    actual_delivery_date         DATE,
    payment_method               VARCHAR,
    payment_status               VARCHAR,
    effective_from               TIMESTAMP,
    effective_to                 TIMESTAMP,
    is_current                   BOOLEAN,
    created_at                   TIMESTAMP,
    updated_at                   TIMESTAMP,
    created_by                   VARCHAR,
    updated_by                   VARCHAR
);

CREATE TABLE order_items (
    order_item_id             SERIAL   PRIMARY KEY,
    order_external_id         UUID     NOT NULL,
    product_sku               VARCHAR  NOT NULL,
    quantity                  INTEGER,
    unit_price                DECIMAL,
    total_price               DECIMAL,
    product_name_snapshot     VARCHAR,
    product_category_snapshot VARCHAR,
    product_brand_snapshot    VARCHAR,
    created_at                TIMESTAMP,
    updated_at                TIMESTAMP,
    created_by                VARCHAR,
    updated_by                VARCHAR,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_external_id)
        REFERENCES orders (order_external_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_sku)
        REFERENCES products (product_sku)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE order_status_history (
    history_id        SERIAL    PRIMARY KEY,
    order_external_id UUID      NOT NULL,
    old_status        VARCHAR,
    new_status        VARCHAR,
    change_reason     VARCHAR,
    changed_at        TIMESTAMP,
    changed_by        VARCHAR,
    session_id        VARCHAR,
    ip_address        INET,
    notes             TEXT,

    CONSTRAINT fk_order_status_history_order
        FOREIGN KEY (order_external_id)
        REFERENCES orders (order_external_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE INDEX idx_orders_user_external_id
    ON orders (user_external_id);

CREATE INDEX idx_orders_order_date
    ON orders (order_date);

CREATE INDEX idx_orders_status
    ON orders (status);

CREATE INDEX idx_order_items_order_external_id
    ON order_items (order_external_id);

CREATE INDEX idx_order_items_product_sku
    ON order_items (product_sku);

CREATE INDEX idx_order_status_history_order_external_id
    ON order_status_history (order_external_id);

CREATE INDEX idx_order_status_history_changed_at
    ON order_status_history (changed_at);

CREATE INDEX idx_products_category
    ON products (category);

CREATE INDEX idx_products_is_active
    ON products (is_active);
