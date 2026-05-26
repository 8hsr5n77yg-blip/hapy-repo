interface Props {
  value: string;
  onChange: (v: string) => void;
}

const KEYS = [
  ['1', '2', '3'],
  ['4', '5', '6'],
  ['7', '8', '9'],
  ['.', '0', '⌫'],
];

export default function AmountInput({ value, onChange }: Props) {
  const handleKey = (k: string) => {
    if (k === '⌫') {
      onChange(value.slice(0, -1));
    } else if (k === '.') {
      if (value.includes('.')) return;
      onChange(value + (value === '' ? '0.' : '.'));
    } else {
      // limit to 2 decimal places
      const parts = value.split('.');
      if (parts.length === 2 && parts[1].length >= 2) return;
      if (value === '0' && k !== '.') {
        onChange(k);
      } else {
        onChange(value + k);
      }
    }
  };

  return (
    <div>
      <div className="text-center py-4">
        <span className="text-4xl font-bold text-gray-800">
          {value ? `¥${value}` : <span className="text-gray-300 text-2xl">输入金额</span>}
        </span>
      </div>
      <div className="space-y-2">
        {KEYS.map((row, i) => (
          <div key={i} className="flex gap-2">
            {row.map(k => (
              <button
                key={k}
                onClick={() => handleKey(k)}
                className="flex-1 py-3 bg-white rounded-xl text-lg font-medium text-gray-700 active:bg-gray-100 transition-colors"
              >
                {k}
              </button>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}
