import { screen, waitFor } from '@testing-library/react'
import { Route, Routes } from 'react-router-dom'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as wordSetsApi from '../api/wordSets'
import { renderWithProviders } from '../test/test-utils'
import WordSetPage from './WordSetPage'

function renderWordSetPage(route = '/word-sets/1') {
  renderWithProviders(
    <Routes>
      <Route path="/word-sets/:id" element={<WordSetPage />} />
    </Routes>,
    { route },
  )
}

describe('WordSetPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('shows word set details and words', async () => {
    vi.spyOn(wordSetsApi, 'fetchWordSet').mockResolvedValue({
      id: 1,
      name: 'Core',
      words_count: 2,
      created_at: '',
      updated_at: '',
    })
    vi.spyOn(wordSetsApi, 'fetchWordSetWords').mockResolvedValue({
      words: [
        {
          id: 10,
          content: '見る',
          kana: 'みる',
          reading: 'みる',
          word_count: 1,
          tags: [],
          frequencies: [],
        },
      ],
      pagination: { page: 1, per_page: 50, total_count: 1, total_pages: 1 },
    })

    renderWordSetPage()

    expect(screen.getByText(/loading word set/i)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Core' })).toBeInTheDocument()
    })

    expect(screen.getByRole('link', { name: '見る' })).toBeInTheDocument()
    expect(screen.getByText('2 words')).toBeInTheDocument()
  })

  it('shows an error when the word set cannot be loaded', async () => {
    vi.spyOn(wordSetsApi, 'fetchWordSet').mockRejectedValue(new Error('Not found'))
    vi.spyOn(wordSetsApi, 'fetchWordSetWords').mockRejectedValue(new Error('Not found'))

    renderWordSetPage()

    expect(await screen.findByText('Not found')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /back to word sets/i })).toHaveAttribute('href', '/')
  })
})
