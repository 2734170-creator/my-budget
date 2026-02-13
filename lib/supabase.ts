import { createBrowserClient, createServerClient } from '@supabase/ssr'
import { type CookieOptions, type Cookies } from 'next/dist/server/web/types'
export function createClient(cookies?: () => Cookies) {
  if (cookies) {
    // Серверный клиент (middleware, page.tsx)
    return createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll: () => cookies().getAll(),
          setAll: (all) => {
            all.forEach(({ name, value, options }) => cookies().set(name, value, options as CookieOptions))
          }
        }
      }
    )
  }
  // Клиентский клиент (компоненты)
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
