import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './hooks/useAuth';
import LoginPage from './pages/LoginPage';
import HomePage from './pages/HomePage';
import AddRecordPage from './pages/AddRecordPage';
import StatisticsPage from './pages/StatisticsPage';
import BottomNav from './components/BottomNav';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  if (loading) return <div style={{ padding: 40 }}>加载中...</div>;
  if (!user) return <Navigate to="/login" replace />;
  return (
    <div className="pb-16">
      {children}
      <BottomNav />
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/" element={<ProtectedRoute><HomePage /></ProtectedRoute>} />
          <Route path="/add" element={<ProtectedRoute><AddRecordPage /></ProtectedRoute>} />
          <Route path="/stats" element={<ProtectedRoute><StatisticsPage /></ProtectedRoute>} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
