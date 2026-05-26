import { useState } from 'react';
import { useNavigate, Navigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export default function LoginPage() {
  const { user, signIn, verifyOtp } = useAuth();
  const navigate = useNavigate();
  const [phone, setPhone] = useState('');
  const [code, setCode] = useState('');
  const [step, setStep] = useState<'phone' | 'code'>('phone');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  if (user) {
    return <Navigate to="/" replace />;
  }

  const handleSendCode = async () => {
    setError('');
    if (!/^1[3-9]\d{9}$/.test(phone)) {
      setError('请输入正确的手机号');
      return;
    }
    setLoading(true);
    const { error: err } = await signIn(`+86${phone}`);
    setLoading(false);
    if (err) {
      setError(err);
    } else {
      setStep('code');
    }
  };

  const handleVerify = async () => {
    setError('');
    if (!code) { setError('请输入验证码'); return; }
    setLoading(true);
    const { error: err } = await verifyOtp(`+86${phone}`, code);
    setLoading(false);
    if (err) {
      setError(err);
    } else {
      navigate('/', { replace: true });
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-6 bg-gradient-to-b from-indigo-50 to-white">
      <div className="w-full max-w-sm">
        <div className="text-center mb-10">
          <div className="text-5xl mb-4">📒</div>
          <h1 className="text-2xl font-bold text-gray-800">小账本</h1>
          <p className="text-gray-400 mt-2 text-sm">大学生专属记账助手</p>
        </div>

        {step === 'phone' ? (
          <div className="space-y-4">
            <div>
              <label className="block text-sm text-gray-500 mb-1">手机号</label>
              <div className="flex items-center bg-gray-50 rounded-xl px-4 py-3 border border-gray-100 focus-within:border-indigo-300 transition-colors">
                <span className="text-gray-400 mr-2 text-sm">+86</span>
                <input
                  type="tel"
                  maxLength={11}
                  className="flex-1 bg-transparent outline-none text-gray-800 text-lg"
                  placeholder="请输入手机号"
                  value={phone}
                  onChange={e => setPhone(e.target.value.replace(/\D/g, ''))}
                />
              </div>
            </div>
            {error && <p className="text-red-400 text-sm">{error}</p>}
            <button
              onClick={handleSendCode}
              disabled={loading}
              className="w-full py-3 bg-indigo-500 text-white rounded-xl text-lg font-medium active:scale-[0.98] transition-transform disabled:opacity-50"
            >
              {loading ? '发送中...' : '获取验证码'}
            </button>
            <p className="text-center text-xs text-gray-400">
              未注册手机号将自动创建账号
            </p>
          </div>
        ) : (
          <div className="space-y-4">
            <p className="text-sm text-gray-500 text-center">
              验证码已发送至 <span className="text-gray-800 font-medium">+86 {phone}</span>
            </p>
            <div>
              <label className="block text-sm text-gray-500 mb-1">验证码</label>
              <input
                type="text"
                maxLength={6}
                className="w-full bg-gray-50 rounded-xl px-4 py-3 border border-gray-100 outline-none focus:border-indigo-300 text-gray-800 text-lg text-center tracking-widest"
                placeholder="输入6位验证码"
                value={code}
                onChange={e => setCode(e.target.value.replace(/\D/g, ''))}
              />
            </div>
            {error && <p className="text-red-400 text-sm">{error}</p>}
            <button
              onClick={handleVerify}
              disabled={loading}
              className="w-full py-3 bg-indigo-500 text-white rounded-xl text-lg font-medium active:scale-[0.98] transition-transform disabled:opacity-50"
            >
              {loading ? '验证中...' : '登录'}
            </button>
            <button
              onClick={() => { setStep('phone'); setError(''); }}
              className="w-full py-2 text-gray-400 text-sm"
            >
              更换手机号
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
