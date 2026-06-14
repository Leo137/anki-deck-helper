import { screen, waitFor } from '@testing-library/react'
import { Route, Routes } from 'react-router-dom'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as decksApi from '../api/decks'
import * as authApi from '../api/auth'
import { setAuthToken } from '../api/client'
import { renderWithProviders } from '../test/test-utils'
import DeckPage from './DeckPage'

function renderDeckPage(route = '/decks/3') {
  renderWithProviders(
    <Routes>
      <Route path="/decks/:id" element={<DeckPage />} />
    </Routes>,
    { route },
  )
}

describe('DeckPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    setAuthToken(null)
  })

  it('shows deck cards in a table', async () => {
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(decksApi, 'fetchDeck').mockResolvedValue({
      id: 3,
      name: 'Favorites',
      status: 'ready',
      error_message: null,
      generation_progress: 100,
      generation_total: 1,
      cards_count: 1,
      created_at: '',
      updated_at: '',
    })
    vi.spyOn(decksApi, 'fetchDeckCards').mockResolvedValue({
      cards: [
        {
          id: 10,
          position: 1,
          front_preview: '半導体',
          created_at: '',
          updated_at: '',
        },
      ],
      pagination: {
        page: 1,
        per_page: 50,
        total_count: 1,
        total_pages: 1,
      },
    })

    renderDeckPage()

    expect(screen.getByText(/loading deck/i)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Favorites' })).toBeInTheDocument()
    })

    expect(screen.getByRole('link', { name: /back to decks/i })).toHaveAttribute('href', '/decks')
    expect(screen.getByRole('link', { name: '半導体' })).toBeInTheDocument()
    expect(screen.getByText('1 card')).toBeInTheDocument()
  })
})
