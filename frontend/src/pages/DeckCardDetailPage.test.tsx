import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Route, Routes } from 'react-router-dom'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as decksApi from '../api/decks'
import * as authApi from '../api/auth'
import { setAuthToken } from '../api/client'
import { renderWithProviders } from '../test/test-utils'
import DeckCardDetailPage from './DeckCardDetailPage'

const baseCard = {
  position: 2,
  created_at: '',
  updated_at: '',
  deck: { id: 5, name: 'Core' },
  fields: [
    {
      id: 1,
      side: 'front' as const,
      html_content: '<h1>だけ</h1>',
      created_at: '',
      updated_at: '',
    },
    {
      id: 2,
      side: 'back' as const,
      html_content: '<div class="definition">* only</div>',
      created_at: '',
      updated_at: '',
    },
  ],
}

function renderDeckCardDetailPage(route = '/decks/5/cards/20') {
  renderWithProviders(
    <Routes>
      <Route path="/decks/:deckId/cards/:id" element={<DeckCardDetailPage />} />
    </Routes>,
    { route },
  )
}

describe('DeckCardDetailPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    setAuthToken(null)
  })

  it('navigates to neighboring cards via buttons and arrow keys', async () => {
    const user = userEvent.setup()
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })

    const fetchDeckCard = vi
      .spyOn(decksApi, 'fetchDeckCard')
      .mockResolvedValueOnce({
        ...baseCard,
        id: 20,
        previous_card_id: 19,
        next_card_id: 21,
      })
      .mockResolvedValueOnce({
        ...baseCard,
        id: 21,
        position: 3,
        previous_card_id: 20,
        next_card_id: null,
      })

    renderDeckCardDetailPage()

    await waitFor(() => {
      expect(screen.getByText('Use ← → arrow keys')).toBeInTheDocument()
    })

    await user.click(screen.getByRole('button', { name: /next card/i }))
    expect(fetchDeckCard).toHaveBeenLastCalledWith(5, 21)

    await waitFor(() => {
      expect(screen.getByText('Card 3')).toBeInTheDocument()
    })

    await user.keyboard('{ArrowLeft}')
    expect(fetchDeckCard).toHaveBeenLastCalledWith(5, 20)
  })
})
