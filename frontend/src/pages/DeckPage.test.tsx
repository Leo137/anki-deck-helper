import { fireEvent, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
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
      study_summary: {
        not_reviewed_count: 1,
        young_count: 0,
        learning_count: 0,
        mature_count: 0,
      },
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
    expect(screen.getByRole('link', { name: 'Study' })).toHaveAttribute('href', '/decks/3/study')
    expect(screen.getByText('1 card')).toBeInTheDocument()
    expect(screen.getByText('Study progress')).toBeInTheDocument()
    expect(screen.getByText('Not reviewed').nextElementSibling).toHaveTextContent('1')
  })

  it('filters cards when the user searches', async () => {
    const user = userEvent.setup()
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(decksApi, 'fetchDeck').mockResolvedValue({
      id: 3,
      name: 'Programming',
      status: 'ready',
      error_message: null,
      generation_progress: 100,
      generation_total: 310,
      cards_count: 310,
      created_at: '',
      updated_at: '',
    })
    const fetchDeckCards = vi
      .spyOn(decksApi, 'fetchDeckCards')
      .mockResolvedValueOnce({
        cards: [
          {
            id: 10,
            position: 1,
            front_preview: '型',
            created_at: '',
            updated_at: '',
          },
          {
            id: 11,
            position: 2,
            front_preview: '要素',
            created_at: '',
            updated_at: '',
          },
        ],
        pagination: {
          page: 1,
          per_page: 50,
          total_count: 2,
          total_pages: 1,
        },
      })
      .mockResolvedValueOnce({
        cards: [
          {
            id: 10,
            position: 1,
            front_preview: '型',
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

    await waitFor(() => {
      expect(screen.getByRole('link', { name: '型' })).toBeInTheDocument()
    })

    await user.type(screen.getByRole('textbox', { name: /search cards/i }), '型')

    expect(screen.getByRole('textbox', { name: /search cards/i })).toHaveValue('型')
    expect(screen.queryByText(/loading deck/i)).not.toBeInTheDocument()

    await waitFor(() => {
      expect(fetchDeckCards).toHaveBeenLastCalledWith(3, 1, 50, '型')
    })

    await waitFor(() => {
      expect(screen.queryByRole('link', { name: '要素' })).not.toBeInTheDocument()
    })
  })

  it('waits until IME composition ends before searching', async () => {
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(decksApi, 'fetchDeck').mockResolvedValue({
      id: 3,
      name: 'Programming',
      status: 'ready',
      error_message: null,
      generation_progress: 100,
      generation_total: 1,
      cards_count: 1,
      created_at: '',
      updated_at: '',
    })
    const fetchDeckCards = vi.spyOn(decksApi, 'fetchDeckCards').mockResolvedValue({
      cards: [
        {
          id: 10,
          position: 1,
          front_preview: '型',
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

    await waitFor(() => {
      expect(screen.getByRole('textbox', { name: /search cards/i })).toBeInTheDocument()
    })

    const input = screen.getByRole('textbox', { name: /search cards/i })
    const initialCalls = fetchDeckCards.mock.calls.length

    fireEvent.compositionStart(input)
    fireEvent.change(input, { target: { value: 'か' } })

    await new Promise((resolve) => setTimeout(resolve, 350))
    expect(fetchDeckCards.mock.calls.length).toBe(initialCalls)

    fireEvent.change(input, { target: { value: '型' } })
    fireEvent.compositionEnd(input, { currentTarget: { value: '型' } })

    await waitFor(() => {
      expect(fetchDeckCards).toHaveBeenLastCalledWith(3, 1, 50, '型')
    })
  })

  it('exports the deck to Anki when the user clicks the export button', async () => {
    const user = userEvent.setup()
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
    const downloadDeckAnkiExport = vi
      .spyOn(decksApi, 'downloadDeckAnkiExport')
      .mockResolvedValue(undefined)

    renderDeckPage()

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /export into an anki deck/i })).toBeInTheDocument()
    })

    await user.click(screen.getByRole('button', { name: /export into an anki deck/i }))

    await waitFor(() => {
      expect(downloadDeckAnkiExport).toHaveBeenCalledWith(3, 'Favorites')
    })
  })
})
