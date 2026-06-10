import { screen, waitFor } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as decksApi from '../api/decks'
import * as authApi from '../api/auth'
import * as wordSetsApi from '../api/wordSets'
import { setAuthToken } from '../api/client'
import { themeClasses } from '../styles/theme'
import { renderWithProviders } from '../test/test-utils'
import HomePage from './HomePage'

describe('HomePage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    setAuthToken(null)
  })

  it('shows loading then word sets for guests', async () => {
    setAuthToken(null)
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockResolvedValue([
      { id: 1, name: 'Core', words_count: 42, created_at: '', updated_at: '' },
    ])

    renderWithProviders(<HomePage />)

    expect(screen.getByText(/loading/i)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Word Sets' })).toBeInTheDocument()
    })

    expect(screen.getByRole('link', { name: /core/i })).toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Decks' })).not.toBeInTheDocument()
  })

  it('shows decks when the user is logged in', async () => {
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockResolvedValue([])
    vi.spyOn(decksApi, 'fetchDecks').mockResolvedValue([
      { id: 1, name: 'SRS Core', words_count: 10, created_at: '', updated_at: '' },
    ])

    renderWithProviders(<HomePage />)

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Decks' })).toBeInTheDocument()
    })

    expect(screen.getByText('SRS Core')).toBeInTheDocument()
  })

  it('shows an error message when loading fails', async () => {
    setAuthToken(null)
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockRejectedValue(new Error('Network error'))

    renderWithProviders(<HomePage />)

    const alert = await screen.findByText(/failed to load content: network error/i)
    expect(alert).toBeInTheDocument()
    expect(alert).toHaveClass('bg-error-bg')
    expect(alert).toHaveClass('text-error-foreground')
  })

  it('applies theme heading classes to the page title', async () => {
    setAuthToken(null)
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockResolvedValue([])

    renderWithProviders(<HomePage />)

    const heading = await screen.findByRole('heading', { name: 'Word Sets' })
    expect(heading.className).toContain(themeClasses.headingXl)
  })
})
