CREATE DATABASE user_service_db;

\connect user_service_db

CREATE TABLE users (
    user_id           SERIAL          PRIMARY KEY,
    user_external_id  UUID            UNIQUE NOT NULL,
    email             VARCHAR         NOT NULL,
    first_name        VARCHAR,
    last_name         VARCHAR,
    phone             VARCHAR,
    date_of_birth     DATE,
    registration_date DATE,
    status            VARCHAR,
    effective_from    TIMESTAMP,
    effective_to      TIMESTAMP,
    is_current        BOOLEAN,
    created_at        TIMESTAMP,
    updated_at        TIMESTAMP,
    created_by        VARCHAR,
    updated_by        VARCHAR
);

CREATE TABLE user_addresses (
    address_id          SERIAL    PRIMARY KEY,
    address_external_id UUID      UNIQUE NOT NULL,
    user_external_id    UUID      NOT NULL,
    address_type        VARCHAR,
    country             VARCHAR,
    region              VARCHAR,
    city                VARCHAR,
    street_address      VARCHAR,
    postal_code         VARCHAR,
    apartment           VARCHAR,
    is_default          BOOLEAN,
    effective_from      TIMESTAMP,
    effective_to        TIMESTAMP,
    is_current          BOOLEAN,
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP,
    created_by          VARCHAR,
    updated_by          VARCHAR,

    CONSTRAINT fk_user_addresses_user
        FOREIGN KEY (user_external_id)
        REFERENCES users (user_external_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE user_status_history (
    history_id       SERIAL    PRIMARY KEY,
    user_external_id UUID      NOT NULL,
    old_status       VARCHAR,
    new_status       VARCHAR,
    change_reason    VARCHAR,
    changed_at       TIMESTAMP,
    changed_by       VARCHAR,
    session_id       VARCHAR,
    ip_address       INET,
    user_agent       VARCHAR,

    CONSTRAINT fk_user_status_history_user
        FOREIGN KEY (user_external_id)
        REFERENCES users (user_external_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE INDEX idx_users_email
    ON users (email);

CREATE INDEX idx_users_status
    ON users (status);

CREATE INDEX idx_user_addresses_user_external_id
    ON user_addresses (user_external_id);

CREATE INDEX idx_user_status_history_user_external_id
    ON user_status_history (user_external_id);

CREATE INDEX idx_user_status_history_changed_at
    ON user_status_history (changed_at);
