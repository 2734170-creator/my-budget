import { createClient } from './lib/supabase'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl
  const supabase = createClient(() => request.cookies)
  const { data: { session } } = await supabase.auth.getSession()
  // Защита маршрутов
  const protectedRoutes = ['/profile', '/dashboard']
  const isProtectedRoute = protectedRoutes.some(route => pathname.startsWith(route))
  if (!session && isProtectedRoute) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  return NextResponse.next()
}
export const config = {
  matcher: ['/profile/:path*', '/dashboard/:path*']
}
