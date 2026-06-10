import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as authApi from '../api/auth'
import { setAuthToken } from '../api/client'
import * as preferencesApi from '../api/preferences'
import { renderWithProviders } from '../test/test-utils'
import PreferencesPage from './PreferencesPage'

describe('PreferencesPage', () => {
  afterEach(() => {
    setAuthToken(null)
  })

  it('prompts guests to log in', async () => {
    setAuthToken(null)
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))

    renderWithProviders(<PreferencesPage />, { route: '/preferences' })

    expect(await screen.findByText(/log in to manage your preferences/i)).toBeInTheDocument()
  })

  it('updates the preferred language for signed-in users', async () => {
    const user = userEvent.setup()
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(preferencesApi, 'fetchPreferences').mockResolvedValue({
      preferred_language: 'en',
      available_languages: ['en', 'ja'],
    })
    vi.spyOn(preferencesApi, 'updatePreferences').mockResolvedValue({
      preferred_language: 'ja',
      available_languages: ['en', 'ja'],
    })

    renderWithProviders(<PreferencesPage />, { route: '/preferences' })

    await waitFor(() => {
      expect(screen.getByLabelText(/preferred definition language/i)).toBeInTheDocument()
    })

    await user.selectOptions(screen.getByLabelText(/preferred definition language/i), 'ja')
    await user.click(screen.getByRole('button', { name: 'Save preferences' }))

    await waitFor(() => {
      expect(screen.getByText('Preferences saved.')).toBeInTheDocument()
    })
    expect(preferencesApi.updatePreferences).toHaveBeenCalledWith('ja')
  })
})
