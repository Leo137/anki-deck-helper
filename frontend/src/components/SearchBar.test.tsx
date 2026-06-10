import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import * as searchApi from '../api/search'
import { renderWithProviders } from '../test/test-utils'
import SearchBar from './SearchBar'

describe('SearchBar', () => {
  beforeEach(() => {
    vi.useFakeTimers({ shouldAdvanceTime: true })
  })

  afterEach(() => {
    vi.restoreAllMocks()
    vi.useRealTimers()
  })

  it('shows search results after debounce', async () => {
    const user = userEvent.setup()
    vi.spyOn(searchApi, 'search').mockResolvedValue({
      query: '食べ',
      words: [{ id: 1, content: '食べる', reading: 'たべる' }],
      word_sets: [{ id: 2, name: 'Core', words_count: 10 }],
    })

    renderWithProviders(<SearchBar />)

    await user.type(screen.getByRole('combobox'), '食べ')

    await waitFor(() => {
      expect(searchApi.search).toHaveBeenCalledWith('食べ')
    })

    expect(await screen.findByText('食べる')).toBeInTheDocument()
    expect(screen.getByText('Core')).toBeInTheDocument()
  })

  it('shows no matches when search returns empty results', async () => {
    const user = userEvent.setup()
    vi.spyOn(searchApi, 'search').mockResolvedValue({
      query: 'zzz',
      words: [],
      word_sets: [],
    })

    renderWithProviders(<SearchBar />)

    await user.type(screen.getByRole('combobox'), 'zzz')

    expect(await screen.findByText(/no matches found/i)).toBeInTheDocument()
  })
})
