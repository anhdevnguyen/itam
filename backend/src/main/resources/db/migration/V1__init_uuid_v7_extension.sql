-- Enable pgcrypto để hỗ trợ sinh UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Hàm sinh UUIDv7: 48 bit timestamp (ms) + version bits + random
-- Đảm bảo khóa chính tăng tuần tự theo thời gian, tối ưu B-Tree index
CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  unix_ts_ms  BYTEA;
  uuid_bytes  BYTEA;
BEGIN
  unix_ts_ms := substring(int8send((extract(epoch FROM clock_timestamp()) * 1000)::BIGINT) FROM 3);
  uuid_bytes := uuid_send(gen_random_uuid());
  -- Ghi 6 byte timestamp vào đầu
  uuid_bytes := overlay(uuid_bytes placing unix_ts_ms FROM 1 FOR 6);
  -- Set version = 7 (4 bit cao của byte thứ 7)
  uuid_bytes := set_byte(uuid_bytes, 6, (b'0111' || substring(get_byte(uuid_bytes, 6)::BIT(8) FROM 5 FOR 4))::BIT(8)::INTEGER);
  RETURN encode(uuid_bytes, 'hex')::UUID;
END
$$;