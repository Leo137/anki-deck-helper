import type { LoginPayload, SignupPayload, User } from '../types/auth'
import { request, setAuthToken } from './client'

export function signup(payload: SignupPayload): Promise<User> {
  return request<User>('/api/v1/auth/signup', {
    method: 'POST',
    auth: false,
    body: { user: payload },
  })
}

export function login(payload: LoginPayload): Promise<User> {
  return request<User>('/api/v1/auth/login', {
    method: 'POST',
    auth: false,
    body: { user: payload },
  })
}

export function fetchCurrentUser(): Promise<User> {
  return request<User>('/api/v1/auth/me')
}

export async function logout(): Promise<void> {
  try {
    await request<void>('/api/v1/auth/logout', { method: 'DELETE' })
  } finally {
    setAuthToken(null)
  }
}
