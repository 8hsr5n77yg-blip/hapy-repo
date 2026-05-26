-- 在 Supabase SQL Editor 中执行以下语句

-- 1. 创建 records 表
CREATE TABLE IF NOT EXISTS records (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
  category TEXT NOT NULL,
  note TEXT DEFAULT '',
  record_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. 创建索引加快查询
CREATE INDEX IF NOT EXISTS idx_records_user_date ON records(user_id, record_date DESC);
CREATE INDEX IF NOT EXISTS idx_records_user_type ON records(user_id, type);

-- 3. 启用 Row Level Security
ALTER TABLE records ENABLE ROW LEVEL SECURITY;

-- 4. RLS 策略：用户只能读写自己的数据
CREATE POLICY "Users can read own records"
  ON records FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own records"
  ON records FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own records"
  ON records FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own records"
  ON records FOR DELETE
  USING (auth.uid() = user_id);
