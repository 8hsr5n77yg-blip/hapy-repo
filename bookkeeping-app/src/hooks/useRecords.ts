import { useState, useEffect, useCallback } from 'react';
import { supabase } from '../supabase';
import { useAuth } from './useAuth';
import { useLocalRecords } from './useLocalStorage';
import type { BillRecord, NewRecord } from '../types';

const IS_LOCAL_MODE = !import.meta.env.VITE_SUPABASE_URL || !import.meta.env.VITE_SUPABASE_ANON_KEY;

function useSupabaseRecords() {
  const { user } = useAuth();
  const [records, setRecords] = useState<BillRecord[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchRecords = useCallback(async (year?: number, month?: number) => {
    if (!user) return;
    setLoading(true);
    const now = new Date();
    const y = year ?? now.getFullYear();
    const m = month ?? now.getMonth() + 1;
    const start = `${y}-${String(m).padStart(2, '0')}-01`;
    const endDate = new Date(y, m, 0).getDate();
    const end = `${y}-${String(m).padStart(2, '0')}-${String(endDate).padStart(2, '0')}`;

    const { data } = await supabase
      .from('records')
      .select('*')
      .eq('user_id', user.id)
      .gte('record_date', start)
      .lte('record_date', end)
      .order('record_date', { ascending: false })
      .order('created_at', { ascending: false });

    setRecords((data as BillRecord[]) || []);
    setLoading(false);
  }, [user]);

  useEffect(() => {
    fetchRecords();
  }, [fetchRecords]);

  const addRecord = async (r: NewRecord) => {
    if (!user) return;
    const { error } = await supabase.from('records').insert({
      user_id: user.id,
      type: r.type,
      amount: r.amount,
      category: r.category,
      note: r.note,
      record_date: r.record_date,
    });
    if (!error) fetchRecords();
    return error?.message;
  };

  const deleteRecord = async (id: string) => {
    const { error } = await supabase.from('records').delete().eq('id', id);
    if (!error) setRecords(prev => prev.filter(r => r.id !== id));
  };

  const totalIncome = records.filter(r => r.type === 'income').reduce((s, r) => s + Number(r.amount), 0);
  const totalExpense = records.filter(r => r.type === 'expense').reduce((s, r) => s + Number(r.amount), 0);

  return { records, loading, fetchRecords, addRecord, deleteRecord, totalIncome, totalExpense };
}

export function useRecords() {
  return IS_LOCAL_MODE ? useLocalRecords() : useSupabaseRecords();
}
