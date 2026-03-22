CREATE DATABASE logistics_service_db;

\connect logistics_service_db

CREATE TABLE warehouses (
    warehouse_id              SERIAL   PRIMARY KEY,
    warehouse_code            VARCHAR  UNIQUE NOT NULL,
    warehouse_name            VARCHAR,
    warehouse_type            VARCHAR,
    country                   VARCHAR,
    region                    VARCHAR,
    city                      VARCHAR,
    street_address            VARCHAR,
    postal_code               VARCHAR,
    is_active                 BOOLEAN,
    max_capacity_cubic_meters DECIMAL,
    operating_hours           VARCHAR,
    contact_phone             VARCHAR,
    manager_name              VARCHAR,
    effective_from            TIMESTAMP,
    effective_to              TIMESTAMP,
    is_current                BOOLEAN,
    created_at                TIMESTAMP,
    updated_at                TIMESTAMP,
    created_by                VARCHAR,
    updated_by                VARCHAR
);

CREATE TABLE pickup_points (
    pickup_point_id       SERIAL   PRIMARY KEY,
    pickup_point_code     VARCHAR  UNIQUE NOT NULL,
    pickup_point_name     VARCHAR,
    pickup_point_type     VARCHAR,
    country               VARCHAR,
    region                VARCHAR,
    city                  VARCHAR,
    street_address        VARCHAR,
    postal_code           VARCHAR,
    is_active             BOOLEAN,
    max_capacity_packages INTEGER,
    operating_hours       VARCHAR,
    contact_phone         VARCHAR,
    partner_name          VARCHAR,
    effective_from        TIMESTAMP,
    effective_to          TIMESTAMP,
    is_current            BOOLEAN,
    created_at            TIMESTAMP,
    updated_at            TIMESTAMP,
    created_by            VARCHAR,
    updated_by            VARCHAR
);

CREATE TABLE shipments (
    shipment_id                     SERIAL    PRIMARY KEY,
    shipment_external_id            UUID      UNIQUE NOT NULL,
    order_external_id               UUID      NOT NULL,
    tracking_number                 VARCHAR,
    status                          VARCHAR,
    weight_grams                    INTEGER,
    volume_cubic_cm                 DECIMAL,
    package_count                   INTEGER,
    origin_warehouse_code           VARCHAR,
    destination_type                VARCHAR,
    destination_pickup_point_code   VARCHAR,
    destination_address_external_id UUID,
    created_date                    DATE,
    dispatched_date                 DATE,
    estimated_delivery_date         DATE,
    actual_delivery_date            DATE,
    delivery_notes                  TEXT,
    recipient_name                  VARCHAR,
    delivery_signature              VARCHAR,
    effective_from                  TIMESTAMP,
    effective_to                    TIMESTAMP,
    is_current                      BOOLEAN,
    created_at                      TIMESTAMP,
    updated_at                      TIMESTAMP,
    created_by                      VARCHAR,
    updated_by                      VARCHAR,

    CONSTRAINT fk_shipments_warehouse
        FOREIGN KEY (origin_warehouse_code)
        REFERENCES warehouses (warehouse_code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_shipments_pickup_point
        FOREIGN KEY (destination_pickup_point_code)
        REFERENCES pickup_points (pickup_point_code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE shipment_movements (
    movement_id          SERIAL    PRIMARY KEY,
    shipment_external_id UUID      NOT NULL,
    movement_type        VARCHAR,
    location_type        VARCHAR,
    location_code        VARCHAR,
    movement_datetime    TIMESTAMP,
    operator_name        VARCHAR,
    notes                TEXT,
    latitude             DECIMAL,
    longitude            DECIMAL,
    created_at           TIMESTAMP,
    created_by           VARCHAR,

    CONSTRAINT fk_shipment_movements_shipment
        FOREIGN KEY (shipment_external_id)
        REFERENCES shipments (shipment_external_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE shipment_status_history (
    history_id           SERIAL    PRIMARY KEY,
    shipment_external_id UUID      NOT NULL,
    old_status           VARCHAR,
    new_status           VARCHAR,
    change_reason        VARCHAR,
    changed_at           TIMESTAMP,
    changed_by           VARCHAR,
    location_type        VARCHAR,
    location_code        VARCHAR,
    notes                TEXT,
    customer_notified    BOOLEAN,

    CONSTRAINT fk_shipment_status_history_shipment
        FOREIGN KEY (shipment_external_id)
        REFERENCES shipments (shipment_external_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE INDEX idx_shipments_order_external_id
    ON shipments (order_external_id);

CREATE INDEX idx_shipments_origin_warehouse_code
    ON shipments (origin_warehouse_code);

CREATE INDEX idx_shipments_status
    ON shipments (status);

CREATE INDEX idx_shipments_created_date
    ON shipments (created_date);

CREATE INDEX idx_shipment_movements_shipment_external_id
    ON shipment_movements (shipment_external_id);

CREATE INDEX idx_shipment_movements_movement_datetime
    ON shipment_movements (movement_datetime);

CREATE INDEX idx_shipment_status_history_shipment_external_id
    ON shipment_status_history (shipment_external_id);

CREATE INDEX idx_warehouses_is_active
    ON warehouses (is_active);

CREATE INDEX idx_pickup_points_is_active
    ON pickup_points (is_active);
