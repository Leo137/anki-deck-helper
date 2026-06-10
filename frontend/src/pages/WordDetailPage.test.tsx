import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Route, Routes, type MemoryRouterProps } from 'react-router-dom'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as wordsApi from '../api/words'
import { renderWithProviders } from '../test/test-utils'
import WordDetailPage from './WordDetailPage'

function renderWordDetailPage(route = '/words/5', routerProps?: Omit<MemoryRouterProps, 'children'>) {
  renderWithProviders(
    <Routes>
      <Route path="/words/:id" element={<WordDetailPage />} />
    </Routes>,
    { route, routerProps },
  )
}

const baseWord = {
  id: 5,
  content: '食べる',
  kana: 'たべる',
  reading: 'たべる',
  word_count: 8,
  tags: ['verb'],
  frequencies: [{ table: 'jpdb', frequency: 100, ratio: 0.5 }],
  word_sets: [{ id: 1, name: 'Core' }],
  available_languages: ['en'],
  dictionary_entries: [
    {
      text: '食べる',
      readings: ['たべる'],
      senses: [{ tags: ['v5r'], definitions: ['to eat'] }],
    },
  ],
}

describe('WordDetailPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('shows word details and dictionary entries', async () => {
    vi.spyOn(wordsApi, 'fetchWord').mockResolvedValue(baseWord)

    renderWordDetailPage()

    expect(screen.getByText(/loading word/i)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: '食べる' })).toBeInTheDocument()
    })

    expect(screen.getByText('to eat')).toBeInTheDocument()
    expect(screen.getByText('verb')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Core' })).toHaveAttribute('href', '/word-sets/1')
    expect(wordsApi.fetchWord).toHaveBeenCalledWith(5, 'en')
  })

  it('shows a language picker and refetches definitions when the language changes', async () => {
    const user = userEvent.setup()
    const fetchWord = vi
      .spyOn(wordsApi, 'fetchWord')
      .mockResolvedValueOnce({
        ...baseWord,
        available_languages: ['en', 'fr'],
      })
      .mockResolvedValueOnce({
        ...baseWord,
        available_languages: ['en', 'fr'],
        dictionary_entries: [
          {
            text: '食べる',
            readings: ['たべる'],
            senses: [{ tags: [], definitions: ['manger'] }],
          },
        ],
      })

    renderWordDetailPage()

    await waitFor(() => {
      expect(screen.getByText('to eat')).toBeInTheDocument()
    })

    await user.selectOptions(screen.getByLabelText(/definitions/i), 'fr')

    await waitFor(() => {
      expect(fetchWord).toHaveBeenLastCalledWith(5, 'fr')
      expect(screen.getByText('manger')).toBeInTheDocument()
    })
  })

  it('hides the language picker when only one language is available', async () => {
    vi.spyOn(wordsApi, 'fetchWord').mockResolvedValue(baseWord)

    renderWordDetailPage()

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: '食べる' })).toBeInTheDocument()
    })

    expect(screen.queryByLabelText(/definitions/i)).not.toBeInTheDocument()
  })

  it('links back to the originating word set when navigation state is present', async () => {
    vi.spyOn(wordsApi, 'fetchWord').mockResolvedValue({
      id: 5,
      content: '食べる',
      kana: null,
      reading: null,
      word_count: 0,
      tags: [],
      frequencies: [],
      word_sets: [],
      available_languages: [],
      dictionary_entries: [],
    })

    renderWordDetailPage('/words/5', {
      initialEntries: [{ pathname: '/words/5', state: { wordSetId: 3, page: 2 } }],
    })

    await waitFor(() => {
      expect(screen.getByRole('link', { name: /back to word set/i })).toHaveAttribute(
        'href',
        '/word-sets/3?page=2',
      )
    })

    expect(screen.getByText(/no dictionary entry found/i)).toBeInTheDocument()
  })

  it('shows an error when the word cannot be loaded', async () => {
    vi.spyOn(wordsApi, 'fetchWord').mockRejectedValue(new Error('Not found'))

    renderWordDetailPage()

    expect(await screen.findByText('Not found')).toBeInTheDocument()
  })
})
