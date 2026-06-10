import { afterEach, describe, expect, it, vi } from 'vitest'
import { fetchWord } from './words'

describe('fetchWord', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('fetches a word by id with English definitions by default', async () => {
    const word = {
      id: 42,
      content: '食べる',
      kana: 'たべる',
      reading: 'たべる',
      word_count: 3,
      tags: ['verb'],
      frequencies: [],
      word_sets: [{ id: 1, name: 'Core' }],
      dictionary_entries: [],
      available_languages: [],
    }

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(word),
      }),
    )

    await expect(fetchWord(42)).resolves.toEqual(word)
    expect(fetch).toHaveBeenCalledWith('/api/v1/words/42?language=en')
  })

  it('requests a specific language when provided', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({}),
      }),
    )

    await fetchWord(42, 'fr')

    expect(fetch).toHaveBeenCalledWith('/api/v1/words/42?language=fr')
  })
})
