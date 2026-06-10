import { screen } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as authApi from '../api/auth'
import { setAuthToken } from '../api/client'
import { renderWithProviders } from '../test/test-utils'
import AuthNav from './AuthNav'

describe('AuthNav', () => {
  afterEach(() => {
    setAuthToken(null)
  })

  it('shows login and signup actions for guests', async () => {
    setAuthToken(null)
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))

    renderWithProviders(<AuthNav />)

    expect(await screen.findByRole('button', { name: 'Log in' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Sign up' })).toBeInTheDocument()
  })

  it('shows the username and logout action for signed-in users', async () => {
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'ja',
    })

    renderWithProviders(<AuthNav />)

    expect(await screen.findByRole('link', { name: 'reader' })).toHaveAttribute('href', '/preferences')
    expect(screen.getByRole('button', { name: 'Log out' })).toBeInTheDocument()
  })
})
