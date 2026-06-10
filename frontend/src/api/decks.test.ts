import { afterEach, describe, expect, it, vi } from 'vitest'
import { fetchDecks } from './decks'

describe('decks API', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('fetchDecks requests the decks index', async () => {
    const decks = [{ id: 1, name: 'SRS Core', words_count: 10, created_at: '', updated_at: '' }]

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(decks),
      }),
    )

    await expect(fetchDecks()).resolves.toEqual(decks)
    expect(fetch).toHaveBeenCalledWith('/api/v1/decks', expect.objectContaining({ method: 'GET' }))
  })
})
