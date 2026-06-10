import { afterEach, describe, expect, it, vi } from 'vitest'
import { fetchWordSet, fetchWordSets, fetchWordSetWords } from './wordSets'

describe('wordSets API', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('fetchWordSets requests the word sets index', async () => {
    const wordSets = [{ id: 1, name: 'Core', words_count: 10, created_at: '', updated_at: '' }]

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(wordSets),
      }),
    )

    await expect(fetchWordSets()).resolves.toEqual(wordSets)
    expect(fetch).toHaveBeenCalledWith('/api/v1/word_sets')
  })

  it('fetchWordSet requests a single word set', async () => {
    const wordSet = { id: 2, name: 'JLPT', words_count: 5, created_at: '', updated_at: '' }

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(wordSet),
      }),
    )

    await expect(fetchWordSet(2)).resolves.toEqual(wordSet)
    expect(fetch).toHaveBeenCalledWith('/api/v1/word_sets/2')
  })

  it('fetchWordSetWords includes pagination query params', async () => {
    const payload = {
      words: [],
      pagination: { page: 2, per_page: 25, total_count: 100, total_pages: 4 },
    }

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(payload),
      }),
    )

    await expect(fetchWordSetWords(3, 2, 25)).resolves.toEqual(payload)
    expect(fetch).toHaveBeenCalledWith('/api/v1/word_sets/3/words?page=2&per_page=25')
  })
})
