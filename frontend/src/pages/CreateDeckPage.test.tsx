import { screen, waitFor } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as decksApi from '../api/decks'
import * as authApi from '../api/auth'
import * as wordSetsApi from '../api/wordSets'
import { setAuthToken } from '../api/client'
import { renderWithProviders } from '../test/test-utils'
import CreateDeckPage from './CreateDeckPage'

describe('CreateDeckPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    setAuthToken(null)
  })

  it('shows a sign-in prompt for guests', async () => {
    setAuthToken(null)
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))

    renderWithProviders(<CreateDeckPage />, { route: '/decks/new' })

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Create deck' })).toBeInTheDocument()
    })

    expect(screen.getByText(/sign in to create decks/i)).toBeInTheDocument()
  })

  it('shows the create form when logged in', async () => {
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockResolvedValue([
      { id: 10, name: 'Core', words_count: 5, created_at: '', updated_at: '' },
    ])
    vi.spyOn(decksApi, 'fetchFrequencyTables').mockResolvedValue([
      { id: 20, name: 'jpdb', created_at: '', updated_at: '' },
    ])

    renderWithProviders(<CreateDeckPage />, { route: '/decks/new' })

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Create deck' })).toBeInTheDocument()
    })

    expect(screen.getByRole('link', { name: /back to decks/i })).toHaveAttribute('href', '/decks')
    expect(screen.getByLabelText(/deck name/i)).toBeInTheDocument()
  })
})
