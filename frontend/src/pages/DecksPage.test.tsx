import { screen, waitFor } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as decksApi from '../api/decks'
import * as authApi from '../api/auth'
import { setAuthToken } from '../api/client'
import { renderWithProviders } from '../test/test-utils'
import DecksPage from './DecksPage'

describe('DecksPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    setAuthToken(null)
  })

  it('shows a sign-in prompt for guests', async () => {
    setAuthToken(null)
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))

    renderWithProviders(<DecksPage />, { route: '/decks' })

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Decks' })).toBeInTheDocument()
    })

    expect(screen.getByText(/sign in to use decks/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Log in' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Sign up' })).toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Create deck' })).not.toBeInTheDocument()
  })

  it('shows decks and a link to create a deck when logged in', async () => {
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(decksApi, 'fetchDecks').mockResolvedValue([
      {
        id: 1,
        name: 'SRS Core',
        status: 'ready',
        error_message: null,
        generation_progress: 100,
        generation_total: 10,
        cards_count: 10,
        created_at: '',
        updated_at: '',
      },
    ])

    renderWithProviders(<DecksPage />, { route: '/decks' })

    await waitFor(() => {
      expect(screen.getByText('SRS Core')).toBeInTheDocument()
    })

    expect(screen.getByRole('link', { name: 'Create deck' })).toHaveAttribute('href', '/decks/new')
    expect(screen.queryByRole('heading', { name: 'Create deck' })).not.toBeInTheDocument()
  })
})
