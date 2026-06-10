import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import * as authApi from '../api/auth'
import { renderWithProviders } from '../test/test-utils'
import AuthModal from './AuthModal'

describe('AuthModal', () => {
  it('validates signup passwords before submitting', async () => {
    const user = userEvent.setup()
    const signup = vi.spyOn(authApi, 'signup')

    renderWithProviders(
      <AuthModal mode="signup" onClose={() => undefined} onSwitchMode={() => undefined} />,
    )

    await user.type(screen.getByLabelText('Email'), 'new@example.com')
    await user.type(screen.getByLabelText('Username'), 'newuser')
    await user.type(screen.getByLabelText('Password'), 'weak')
    await user.type(screen.getByLabelText('Password confirmation'), 'weak')
    await user.click(screen.getByRole('button', { name: 'Sign up' }))

    expect(
      screen.getByText(/must be at least 8 characters and include one uppercase letter/i),
    ).toBeInTheDocument()
    expect(signup).not.toHaveBeenCalled()
  })

  it('submits signup with valid credentials', async () => {
    const user = userEvent.setup()
    vi.spyOn(authApi, 'signup').mockResolvedValue({
      id: 1,
      email: 'new@example.com',
      username: 'newuser',
      preferred_language: 'en',
    })
    const onClose = vi.fn()

    renderWithProviders(
      <AuthModal mode="signup" onClose={onClose} onSwitchMode={() => undefined} />,
    )

    await user.type(screen.getByLabelText('Email'), 'new@example.com')
    await user.type(screen.getByLabelText('Username'), 'newuser')
    await user.type(screen.getByLabelText('Password'), 'Password1!')
    await user.type(screen.getByLabelText('Password confirmation'), 'Password1!')
    await user.click(screen.getByRole('button', { name: 'Sign up' }))

    await waitFor(() => {
      expect(onClose).toHaveBeenCalled()
    })
  })
})
