import { CATEGORY_ICONS } from '../types';

interface Props {
  categories: string[];
  selected: string;
  onSelect: (cat: string) => void;
}

export default function CategoryPicker({ categories, selected, onSelect }: Props) {
  return (
    <div>
      <label className="block text-sm text-gray-500 mb-2">分类</label>
      <div className="grid grid-cols-4 gap-2">
        {categories.map(cat => (
          <button
            key={cat}
            onClick={() => onSelect(cat)}
            className={`flex flex-col items-center py-3 rounded-xl text-xs transition-all active:scale-95 ${
              selected === cat
                ? 'bg-indigo-50 text-indigo-600 font-medium ring-1 ring-indigo-200'
                : 'bg-white text-gray-500'
            }`}
          >
            <span className="text-xl mb-1">{CATEGORY_ICONS[cat] || '📌'}</span>
            {cat}
          </button>
        ))}
      </div>
    </div>
  );
}
