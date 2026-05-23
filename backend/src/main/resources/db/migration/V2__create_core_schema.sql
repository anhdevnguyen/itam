-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE users (
    id            UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    role          VARCHAR(20)  NOT NULL CHECK (role IN ('ADMIN', 'EMPLOYEE')),
    is_deleted    BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- CATEGORIES
-- ============================================================
CREATE TABLE categories (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    is_deleted  BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ASSETS
-- ============================================================
CREATE TABLE assets (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    serial_number   VARCHAR(100) NOT NULL UNIQUE,
    name            VARCHAR(200) NOT NULL,
    category_id     UUID         NOT NULL REFERENCES categories(id),
    status          VARCHAR(20)  NOT NULL CHECK (status IN ('AVAILABLE','IN_USE','MAINTENANCE','RETIRED'))
                                 DEFAULT 'AVAILABLE',
    condition_notes TEXT,
    is_deleted      BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- BORROW REQUESTS
-- ============================================================
CREATE TABLE borrow_requests (
    id                   UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id              UUID        NOT NULL REFERENCES users(id),
    asset_id             UUID        NOT NULL REFERENCES assets(id),
    request_reason       TEXT,
    start_date           DATE        NOT NULL,
    expected_return_date DATE        NOT NULL,
    actual_return_date   DATE,
    status               VARCHAR(20) NOT NULL CHECK (status IN ('PENDING','APPROVED','REJECTED','RETURNED'))
                                     DEFAULT 'PENDING',
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ASSET HISTORIES (Audit trail)
-- ============================================================
CREATE TABLE asset_histories (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    asset_id    UUID        NOT NULL REFERENCES assets(id),
    actor_id    UUID        NOT NULL REFERENCES users(id),
    action      VARCHAR(30) NOT NULL CHECK (action IN ('CREATED','ASSIGNED','RETURNED','SENT_TO_REPAIR','RETIRED')),
    from_status VARCHAR(20),
    to_status   VARCHAR(20),
    note        TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- INDEXES — phụ trợ cho các truy vấn lọc thường xuyên
-- ============================================================
-- Chỉ mục có điều kiện: bỏ qua bản ghi đã soft-delete, thu hẹp phạm vi quét
CREATE INDEX idx_assets_status      ON assets(status)      WHERE is_deleted = FALSE;
CREATE INDEX idx_assets_category_id ON assets(category_id) WHERE is_deleted = FALSE;

CREATE INDEX idx_borrow_user_id ON borrow_requests(user_id);
CREATE INDEX idx_borrow_status  ON borrow_requests(status);

CREATE INDEX idx_asset_histories_asset_id ON asset_histories(asset_id);