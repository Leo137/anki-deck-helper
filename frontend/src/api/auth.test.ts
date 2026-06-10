import { afterEach, describe, expect, it, vi } from 'vitest'
import { login, logout, signup } from './auth'
import { getAuthToken, setAuthToken } from './client'

describe('auth api', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    setAuthToken(null)
  })

  it('stores the JWT from signup responses', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        status: 201,
        headers: new Headers({ Authorization: 'Bearer signup-token' }),
        json: () =>
          Promise.resolve({
            id: 1,
            email: 'new@example.com',
            username: 'newuser',
            preferred_language: 'en',
          }),
      }),
    )

    await signup({
      email: 'new@example.com',
      username: 'newuser',
      password: 'Password1!',
      password_confirmation: 'Password1!',
    })

    expect(getAuthToken()).toBe('Bearer signup-token')
  })

  it('stores the JWT from login responses', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        headers: new Headers({ Authorization: 'Bearer login-token' }),
        json: () =>
          Promise.resolve({
            id: 2,
            email: 'reader@example.com',
            username: 'reader',
            preferred_language: 'ja',
          }),
      }),
    )

    await login({ email: 'reader@example.com', password: 'Password1!' })

    expect(getAuthToken()).toBe('Bearer login-token')
  })

  it('clears the stored token on logout', async () => {
    setAuthToken('Bearer existing-token')
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        status: 200,
        headers: new Headers(),
        json: () => Promise.resolve({ message: 'Logged out successfully' }),
      }),
    )

    await logout()

    expect(getAuthToken()).toBeNull()
  })
})
