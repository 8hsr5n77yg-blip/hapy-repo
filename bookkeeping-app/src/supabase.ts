import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

function getSupabase() {
  if (!supabaseUrl || !supabaseAnonKey) {
    // Return a proxy that throws on access when Supabase is not configured.
    // This should never be reached in local mode because IS_LOCAL_MODE
    // guards prevent Supabase calls in the first place.
    return new Proxy({} as ReturnType<typeof createClient>, {
      get() {
        throw new Error('Supabase is not configured.');
      },
    });
  }
  return createClient(supabaseUrl, supabaseAnonKey);
}

export const supabase = getSupabase();
