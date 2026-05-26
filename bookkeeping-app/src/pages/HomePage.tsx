import { useNavigate } from 'react-router-dom';
import { useRecords } from '../hooks/useRecords';
import RecordItem from '../components/RecordItem';

export default function HomePage() {
  const { records, loading, deleteRecord, totalIncome, totalExpense } = useRecords();
  const navigate = useNavigate();
  const balance = totalIncome - totalExpense;

  const grouped = records.reduce<Record<string, typeof records>>((acc, r) => {
    const key = r.record_date;
    if (!acc[key]) acc[key] = [];
    acc[key].push(r);
    return acc;
  }, {});

  const now = new Date();
  const monthLabel = `${now.getFullYear()}年${now.getMonth() + 1}月`;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* 月度概览卡片 */}
      <div className="bg-indigo-500 text-white px-5 pt-10 pb-8 rounded-b-3xl">
        <h2 className="text-sm opacity-80 mb-1">{monthLabel}</h2>
        <div className="flex justify-between items-end mt-3">
          <div>
            <p className="text-xs opacity-70">结余</p>
            <p className="text-3xl font-bold">{balance >= 0 ? '' : '-'}¥{Math.abs(balance).toFixed(2)}</p>
          </div>
          <button
            onClick={() => navigate('/add')}
            className="bg-white text-indigo-500 px-5 py-2.5 rounded-full font-semibold text-sm active:scale-95 transition-transform shadow-lg"
          >
            + 记一笔
          </button>
        </div>
        <div className="flex gap-6 mt-5">
          <div>
            <p className="text-xs opacity-70">收入</p>
            <p className="text-lg font-semibold text-green-200">¥{totalIncome.toFixed(2)}</p>
          </div>
          <div>
            <p className="text-xs opacity-70">支出</p>
            <p className="text-lg font-semibold text-red-200">¥{totalExpense.toFixed(2)}</p>
          </div>
        </div>
      </div>

      {/* 账单列表 */}
      <div className="px-4 py-4">
        {loading ? (
          <p className="text-center text-gray-400 py-8">加载中...</p>
        ) : records.length === 0 ? (
          <div className="text-center py-16">
            <p className="text-4xl mb-3">📝</p>
            <p className="text-gray-400">还没有记账，点"+ 记一笔"开始吧</p>
          </div>
        ) : (
          Object.entries(grouped).map(([date, items]) => (
            <div key={date} className="mb-4">
              <div className="flex justify-between items-center mb-2 px-1">
                <span className="text-xs text-gray-400">{date}</span>
                <span className="text-xs text-gray-400">
                  共{items.length}笔
                </span>
              </div>
              <div className="bg-white rounded-xl overflow-hidden shadow-sm">
                {items.map((r, i) => (
                  <RecordItem
                    key={r.id}
                    record={r}
                    onDelete={deleteRecord}
                    showDivider={i < items.length - 1}
                  />
                ))}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
