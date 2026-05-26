import { useState, useCallback } from 'react';
import type { BillRecord, NewRecord } from '../types';

const STORAGE_KEY = 'xiaozhangben_records';

function loadRecords(): BillRecord[] {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
  } catch {
    return [];
  }
}

function saveRecords(records: BillRecord[]) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
}

export function useLocalRecords() {
  const [records, setRecords] = useState<BillRecord[]>(loadRecords);

  const addRecord = useCallback(async (r: NewRecord) => {
    const newRecord: BillRecord = {
      id: Date.now().toString(),
      user_id: 'local',
      ...r,
      created_at: new Date().toISOString(),
    };
    const updated = [newRecord, ...loadRecords()];
    saveRecords(updated);
    setRecords(updated);
  }, []);

  const deleteRecord = useCallback((id: string) => {
    const updated = loadRecords().filter(r => r.id !== id);
    saveRecords(updated);
    setRecords(updated);
  }, []);

  const fetchRecords = useCallback((_year?: number, _month?: number) => {
    const all = loadRecords();
    const now = new Date();
    const y = _year ?? now.getFullYear();
    const m = _month ?? now.getMonth() + 1;
    const filtered = all.filter(r => {
      const d = new Date(r.record_date);
      return d.getFullYear() === y && d.getMonth() + 1 === m;
    });
    setRecords(filtered);
  }, []);

  const totalIncome = records.filter(r => r.type === 'income').reduce((s, r) => s + r.amount, 0);
  const totalExpense = records.filter(r => r.type === 'expense').reduce((s, r) => s + r.amount, 0);

  return { records, loading: false, fetchRecords, addRecord, deleteRecord, totalIncome, totalExpense };
}
