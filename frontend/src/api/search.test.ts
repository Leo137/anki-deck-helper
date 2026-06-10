import { afterEach, describe, expect, it, vi } from 'vitest'
import { search } from './search'

describe('search', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('requests search results with the query param', async () => {
    const results = {
      query: '食べ',
      words: [{ id: 1, content: '食べる', reading: 'たべる' }],
      word_sets: [],
    }

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(results),
      }),
    )

    await expect(search('食べ')).resolves.toEqual(results)
    expect(fetch).toHaveBeenCalledWith('/api/v1/search?q=%E9%A3%9F%E3%81%B9')
  })
})
