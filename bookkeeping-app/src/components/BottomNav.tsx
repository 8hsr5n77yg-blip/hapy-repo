import { useLocation, useNavigate } from 'react-router-dom';

const tabs = [
  { path: '/', label: '首页', icon: '🏠' },
  { path: '/add', label: '记账', icon: '➕' },
  { path: '/stats', label: '统计', icon: '📊' },
];

export default function BottomNav() {
  const location = useLocation();
  const navigate = useNavigate();

  return (
    <nav className="fixed bottom-0 w-full max-w-md bg-white border-t border-gray-100 flex justify-around py-2 safe-area-bottom">
      {tabs.map(t => {
        const active = location.pathname === t.path;
        return (
          <button
            key={t.path}
            onClick={() => navigate(t.path)}
            className={`flex flex-col items-center px-3 py-1 rounded-lg transition-colors ${
              active ? 'text-indigo-500' : 'text-gray-400'
            }`}
          >
            <span className="text-xl">{t.icon}</span>
            <span className="text-[10px] mt-0.5 font-medium">{t.label}</span>
          </button>
        );
      })}
    </nav>
  );
}
