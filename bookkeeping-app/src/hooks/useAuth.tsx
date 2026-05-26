import { useState, useEffect, createContext, useContext, type ReactNode } from 'react';
import { supabase } from '../supabase';
import type { User } from '@supabase/supabase-js';

const IS_LOCAL_MODE = !import.meta.env.VITE_SUPABASE_URL || !import.meta.env.VITE_SUPABASE_ANON_KEY;

const MOCK_USER = {
  id: 'local-user',
  phone: '13800138000',
} as unknown as User;

interface AuthState {
  user: User | null;
  loading: boolean;
  signIn: (phone: string) => Promise<{ error?: string }>;
  verifyOtp: (phone: string, token: string) => Promise<{ error?: string }>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthState | null>(null);

function LocalAuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(() => {
    const saved = localStorage.getItem('xiaozhangben_local_auth');
    return saved ? MOCK_USER : null;
  });

  const signIn = async (_phone: string) => {
    return {};
  };

  const verifyOtp = async (_phone: string, _token: string) => {
    localStorage.setItem('xiaozhangben_local_auth', '1');
    setUser(MOCK_USER);
    return {};
  };

  const signOut = async () => {
    localStorage.removeItem('xiaozhangben_local_auth');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, loading: false, signIn, verifyOtp, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

function SupabaseAuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null);
      setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    return () => subscription.unsubscribe();
  }, []);

  const signIn = async (phone: string) => {
    const { error } = await supabase.auth.signInWithOtp({
      phone,
      options: { shouldCreateUser: true },
    });
    if (error) return { error: error.message };
    return {};
  };

  const verifyOtp = async (phone: string, token: string) => {
    const { error } = await supabase.auth.verifyOtp({
      phone,
      token,
      type: 'sms',
    });
    if (error) return { error: error.message };
    return {};
  };

  const signOut = async () => {
    await supabase.auth.signOut();
  };

  return (
    <AuthContext.Provider value={{ user, loading, signIn, verifyOtp, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function AuthProvider({ children }: { children: ReactNode }) {
  return IS_LOCAL_MODE
    ? <LocalAuthProvider>{children}</LocalAuthProvider>
    : <SupabaseAuthProvider>{children}</SupabaseAuthProvider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
