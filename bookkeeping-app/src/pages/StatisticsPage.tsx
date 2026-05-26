import { useState, useMemo } from 'react';
import { useRecords } from '../hooks/useRecords';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
import { CATEGORY_COLORS } from '../types';

export default function StatisticsPage() {
  const { records, fetchRecords } = useRecords();
  const now = new Date();
  const [year, setYear] = useState(now.getFullYear());
  const [month, setMonth] = useState(now.getMonth() + 1);

  const handleMonthChange = (dir: -1 | 1) => {
    let m = month + dir;
    let y = year;
    if (m < 1) { m = 12; y--; }
    if (m > 12) { m = 1; y++; }
    setMonth(m);
    setYear(y);
    fetchRecords(y, m);
  };

  const expenseByCategory = useMemo(() => {
    const map: Record<string, number> = {};
    records.filter(r => r.type === 'expense').forEach(r => {
      map[r.category] = (map[r.category] || 0) + Number(r.amount);
    });
    return Object.entries(map).map(([name, value]) => ({ name, value: Math.round(value * 100) / 100 }));
  }, [records]);

  const incomeByCategory = useMemo(() => {
    const map: Record<string, number> = {};
    records.filter(r => r.type === 'income').forEach(r => {
      map[r.category] = (map[r.category] || 0) + Number(r.amount);
    });
    return Object.entries(map).map(([name, value]) => ({ name, value: Math.round(value * 100) / 100 }));
  }, [records]);

  const totalE = expenseByCategory.reduce((s, i) => s + i.value, 0);
  const totalI = incomeByCategory.reduce((s, i) => s + i.value, 0);

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white px-5 pt-8 pb-4">
        <h2 className="text-lg font-bold text-gray-800">统计分析</h2>
        <div className="flex items-center justify-center gap-4 mt-3">
          <button onClick={() => handleMonthChange(-1)} className="text-gray-400 text-lg px-2">&lsaquo;</button>
          <span className="font-semibold text-gray-700">{year}年{month}月</span>
          <button onClick={() => handleMonthChange(1)} className="text-gray-400 text-lg px-2">&rsaquo;</button>
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* 支出饼图 */}
        <div className="bg-white rounded-xl p-4 shadow-sm">
          <div className="flex justify-between items-center mb-2">
            <h3 className="font-semibold text-gray-700">支出分类</h3>
            <span className="text-sm text-gray-400">合计 ¥{totalE.toFixed(2)}</span>
          </div>
          {expenseByCategory.length === 0 ? (
            <p className="text-center text-gray-300 py-8 text-sm">暂无支出数据</p>
          ) : (
            <>
              <ResponsiveContainer width="100%" height={180}>
                <PieChart>
                  <Pie
                    data={expenseByCategory}
                    cx="50%"
                    cy="50%"
                    innerRadius={40}
                    outerRadius={75}
                    paddingAngle={3}
                    dataKey="value"
                  >
                    {expenseByCategory.map(e => (
                      <Cell key={e.name} fill={CATEGORY_COLORS[e.name] || '#6b7280'} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(v) => `¥${Number(v).toFixed(2)}`} />
                </PieChart>
              </ResponsiveContainer>
              <div className="flex flex-wrap gap-2 mt-2">
                {expenseByCategory.map(e => (
                  <span key={e.name} className="text-xs bg-gray-50 px-2 py-1 rounded-full text-gray-600">
                    {e.name} ¥{e.value.toFixed(0)}
                  </span>
                ))}
              </div>
            </>
          )}
        </div>

        {/* 收入饼图 */}
        <div className="bg-white rounded-xl p-4 shadow-sm">
          <div className="flex justify-between items-center mb-2">
            <h3 className="font-semibold text-gray-700">收入来源</h3>
            <span className="text-sm text-gray-400">合计 ¥{totalI.toFixed(2)}</span>
          </div>
          {incomeByCategory.length === 0 ? (
            <p className="text-center text-gray-300 py-8 text-sm">暂无收入数据</p>
          ) : (
            <>
              <ResponsiveContainer width="100%" height={180}>
                <PieChart>
                  <Pie
                    data={incomeByCategory}
                    cx="50%"
                    cy="50%"
                    innerRadius={40}
                    outerRadius={75}
                    paddingAngle={3}
                    dataKey="value"
                  >
                    {incomeByCategory.map(e => (
                      <Cell key={e.name} fill={CATEGORY_COLORS[e.name] || '#6b7280'} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(v) => `¥${Number(v).toFixed(2)}`} />
                </PieChart>
              </ResponsiveContainer>
              <div className="flex flex-wrap gap-2 mt-2">
                {incomeByCategory.map(e => (
                  <span key={e.name} className="text-xs bg-gray-50 px-2 py-1 rounded-full text-gray-600">
                    {e.name} ¥{e.value.toFixed(0)}
                  </span>
                ))}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
