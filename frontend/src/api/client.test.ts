import { afterEach, describe, expect, it, vi } from 'vitest'
import { request } from './client'

describe('request', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('returns parsed JSON on success', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ id: 1 }),
      }),
    )

    await expect(request('/api/v1/words/1')).resolves.toEqual({ id: 1 })
    expect(fetch).toHaveBeenCalledWith('/api/v1/words/1', {
      method: 'GET',
      headers: expect.any(Headers),
      body: undefined,
    })
  })

  it('throws "Not found" on 404', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: false,
        status: 404,
      }),
    )

    await expect(request('/api/v1/words/999')).rejects.toThrow('Not found')
  })

  it('throws a status message on other errors', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: false,
        status: 500,
      }),
    )

    await expect(request('/api/v1/words')).rejects.toThrow('Request failed (500)')
  })
})
