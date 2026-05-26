import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useRecords } from '../hooks/useRecords';
import CategoryPicker from '../components/CategoryPicker';
import AmountInput from '../components/AmountInput';
import type { RecordType } from '../types';
import { EXPENSE_CATEGORIES, INCOME_CATEGORIES } from '../types';

export default function AddRecordPage() {
  const navigate = useNavigate();
  const { addRecord } = useRecords();
  const [type, setType] = useState<RecordType>('expense');
  const [amount, setAmount] = useState('');
  const [category, setCategory] = useState('餐饮');
  const [note, setNote] = useState('');
  const [date, setDate] = useState(() => new Date().toISOString().slice(0, 10));
  const [saving, setSaving] = useState(false);

  const cats = type === 'expense' ? EXPENSE_CATEGORIES : INCOME_CATEGORIES;

  const handleSave = async () => {
    const amt = parseFloat(amount);
    if (!amt || amt <= 0) return;
    setSaving(true);
    const err = await addRecord({
      type,
      amount: amt,
      category: category || cats[0],
      note,
      record_date: date,
    });
    setSaving(false);
    if (!err) navigate('/', { replace: true });
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* 顶部 */}
      <div className="bg-white px-4 py-3 flex items-center justify-between border-b border-gray-100">
        <button onClick={() => navigate(-1)} className="text-gray-500 text-lg px-1">&larr;</button>
        <h1 className="font-semibold text-gray-800">记一笔</h1>
        <div className="w-8" />
      </div>

      <div className="px-4 py-6 space-y-6">
        {/* 收支类型切换 */}
        <div className="flex bg-gray-100 rounded-xl p-1">
          <button
            onClick={() => { setType('expense'); setCategory('餐饮'); }}
            className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
              type === 'expense' ? 'bg-white text-red-500 shadow-sm' : 'text-gray-400'
            }`}
          >
            支出
          </button>
          <button
            onClick={() => { setType('income'); setCategory('生活费'); }}
            className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
              type === 'income' ? 'bg-white text-green-500 shadow-sm' : 'text-gray-400'
            }`}
          >
            收入
          </button>
        </div>

        {/* 金额输入 */}
        <AmountInput value={amount} onChange={setAmount} />

        {/* 分类选择 */}
        <CategoryPicker
          categories={[...cats]}
          selected={category}
          onSelect={setCategory}
        />

        {/* 日期 */}
        <div>
          <label className="block text-sm text-gray-500 mb-1">日期</label>
          <input
            type="date"
            value={date}
            onChange={e => setDate(e.target.value)}
            className="w-full bg-white rounded-xl px-4 py-3 border border-gray-100 outline-none focus:border-indigo-300 text-gray-800"
          />
        </div>

        {/* 备注 */}
        <div>
          <label className="block text-sm text-gray-500 mb-1">备注（可选）</label>
          <input
            type="text"
            placeholder="写点什么..."
            value={note}
            onChange={e => setNote(e.target.value)}
            className="w-full bg-white rounded-xl px-4 py-3 border border-gray-100 outline-none focus:border-indigo-300 text-gray-800"
          />
        </div>

        {/* 保存按钮 */}
        <button
          onClick={handleSave}
          disabled={saving || !amount}
          className="w-full py-3.5 bg-indigo-500 text-white rounded-xl text-lg font-semibold active:scale-[0.98] transition-transform disabled:opacity-40"
        >
          {saving ? '保存中...' : '保存'}
        </button>
      </div>
    </div>
  );
}
