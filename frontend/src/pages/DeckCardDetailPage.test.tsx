import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Route, Routes } from 'react-router-dom'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as decksApi from '../api/decks'
import * as authApi from '../api/auth'
import { setAuthToken } from '../api/client'
import { renderWithProviders } from '../test/test-utils'
import type { DeckCardDetail } from '../types/deck'
import DeckCardDetailPage from './DeckCardDetailPage'

const baseCard = {
  position: 2,
  created_at: '',
  updated_at: '',
  deck: { id: 5, name: 'Core' },
  study_stats: {
    know_count: 0,
    dont_know_count: 0,
    total_responses: 0,
    accuracy_rate: null,
    last_responded_at: null,
    last_correct: null,
  },
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

    let resolveNextCard: (card: DeckCardDetail) => void = () => {}
    const nextCardPromise = new Promise<DeckCardDetail>((resolve) => {
      resolveNextCard = resolve
    })

    const fetchDeckCard = vi
      .spyOn(decksApi, 'fetchDeckCard')
      .mockResolvedValueOnce({
        ...baseCard,
        id: 20,
        previous_card_id: 19,
        next_card_id: 21,
      })
      .mockImplementationOnce(() => nextCardPromise)
      .mockResolvedValueOnce({
        ...baseCard,
        id: 20,
        previous_card_id: 19,
        next_card_id: 21,
      })

    renderDeckCardDetailPage()

    await waitFor(() => {
      expect(screen.getByText('Use ← → arrow keys')).toBeInTheDocument()
    })

    await user.click(screen.getByRole('button', { name: /next card/i }))
    expect(fetchDeckCard).toHaveBeenLastCalledWith(5, 21)
    expect(screen.queryByText(/^loading card…$/i)).not.toBeInTheDocument()
    expect(screen.getByRole('link', { name: /back to core/i })).toBeInTheDocument()
    expect(screen.getByText('だけ')).toBeInTheDocument()
    expect(screen.getByText('Card 2')).toBeInTheDocument()
    expect(screen.getByText('Fetching…')).toBeInTheDocument()

    resolveNextCard({
      ...baseCard,
      id: 21,
      position: 3,
      previous_card_id: 20,
      next_card_id: null,
    })

    await waitFor(() => {
      expect(screen.getByText('Card 3')).toBeInTheDocument()
    })

    await user.keyboard('{ArrowLeft}')

    await waitFor(() => {
      expect(fetchDeckCard).toHaveBeenLastCalledWith(5, 20)
    })
  })

  it('shows study stats when responses exist', async () => {
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(decksApi, 'fetchDeckCard').mockResolvedValue({
      ...baseCard,
      id: 20,
      previous_card_id: null,
      next_card_id: null,
      study_stats: {
        know_count: 3,
        dont_know_count: 1,
        total_responses: 4,
        accuracy_rate: 0.75,
        last_responded_at: '2026-06-14T12:00:00Z',
        last_correct: true,
      },
    })

    renderDeckCardDetailPage()

    await waitFor(() => {
      expect(screen.getByText('Study stats')).toBeInTheDocument()
    })

    expect(screen.getByText('75%')).toBeInTheDocument()
    expect(screen.getByText('Last response').nextElementSibling).toHaveTextContent('Know')
  })
})
