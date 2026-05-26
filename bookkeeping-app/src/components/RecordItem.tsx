import type { BillRecord } from '../types';
import { CATEGORY_ICONS } from '../types';

interface Props {
  record: BillRecord;
  onDelete: (id: string) => void;
  showDivider: boolean;
}

export default function RecordItem({ record, onDelete, showDivider }: Props) {
  const isExpense = record.type === 'expense';
  const icon = CATEGORY_ICONS[record.category] || '📌';

  return (
    <div className={`flex items-center px-4 py-3 ${showDivider ? 'border-b border-gray-50' : ''}`}>
      <span className="text-2xl mr-3">{icon}</span>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium text-gray-800 truncate">{record.category}</p>
        {record.note && <p className="text-xs text-gray-400 truncate mt-0.5">{record.note}</p>}
      </div>
      <span className={`text-sm font-semibold mr-3 ${isExpense ? 'text-red-400' : 'text-green-500'}`}>
        {isExpense ? '-' : '+'}¥{Number(record.amount).toFixed(2)}
      </span>
      <button
        onClick={() => onDelete(record.id)}
        className="text-gray-300 hover:text-red-400 text-sm px-1 transition-colors"
      >
        🗑
      </button>
    </div>
  );
}
