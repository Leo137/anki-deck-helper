import { screen, waitFor } from '@testing-library/react'
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

describe('WordDetailPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('shows word details and dictionary entries', async () => {
    vi.spyOn(wordsApi, 'fetchWord').mockResolvedValue({
      id: 5,
      content: '食べる',
      kana: 'たべる',
      reading: 'たべる',
      word_count: 8,
      tags: ['verb'],
      frequencies: [{ table: 'jpdb', frequency: 100, ratio: 0.5 }],
      word_sets: [{ id: 1, name: 'Core' }],
      dictionary_entries: [
        {
          text: '食べる',
          readings: ['たべる'],
          senses: [{ tags: ['v5r'], definitions: ['to eat'] }],
        },
      ],
    })

    renderWordDetailPage()

    expect(screen.getByText(/loading word/i)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: '食べる' })).toBeInTheDocument()
    })

    expect(screen.getByText('to eat')).toBeInTheDocument()
    expect(screen.getByText('verb')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Core' })).toHaveAttribute('href', '/word-sets/1')
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
