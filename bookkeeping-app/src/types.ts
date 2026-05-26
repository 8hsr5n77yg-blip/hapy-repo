export type RecordType = 'income' | 'expense';

export interface BillRecord {
  id: string;
  user_id: string;
  type: RecordType;
  amount: number;
  category: string;
  note: string;
  record_date: string;
  created_at: string;
}

export interface NewRecord {
  type: RecordType;
  amount: number;
  category: string;
  note: string;
  record_date: string;
}

export const EXPENSE_CATEGORIES = ['餐饮', '购物', '交通', '娱乐', '学习', '日用', '其他'] as const;
export const INCOME_CATEGORIES = ['生活费', '兼职', '红包', '退款', '其他'] as const;

export const CATEGORY_ICONS: Record<string, string> = {
  '餐饮': '🍔', '购物': '🛒', '交通': '🚌', '娱乐': '🎮',
  '学习': '📚', '日用': '🧴', '其他': '📌',
  '生活费': '💰', '兼职': '💼', '红包': '🧧', '退款': '↩️',
};

export const CATEGORY_COLORS: Record<string, string> = {
  '餐饮': '#f97316', '购物': '#ec4899', '交通': '#06b6d4', '娱乐': '#8b5cf6',
  '学习': '#22c55e', '日用': '#eab308', '其他': '#6b7280',
  '生活费': '#22c55e', '兼职': '#3b82f6', '红包': '#ef4444', '退款': '#8b5cf6',
};
