import { afterEach, describe, expect, it, vi } from 'vitest'
import { createDeck, fetchDecks, fetchDeck, fetchFrequencyTables } from './decks'

describe('decks API', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('fetchDecks requests the decks index', async () => {
    const decks = [
      {
        id: 1,
        name: 'SRS Core',
        status: 'ready',
        error_message: null,
        generation_progress: 100,
        generation_total: 10,
        cards_count: 10,
        created_at: '',
        updated_at: '',
      },
    ]

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

  it('createDeck posts deck creation params', async () => {
    const deck = {
      id: 2,
      name: 'Daily Review',
      status: 'pending',
      error_message: null,
      generation_progress: 0,
      generation_total: null,
      cards_count: 0,
      created_at: '',
      updated_at: '',
    }

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        status: 202,
        json: () => Promise.resolve(deck),
      }),
    )

    await expect(
      createDeck({ name: 'Daily Review', word_set_ids: [1], frequency_table_ids: [2] }),
    ).resolves.toEqual(deck)
    expect(fetch).toHaveBeenCalledWith(
      '/api/v1/decks',
      expect.objectContaining({
        method: 'POST',
        body: JSON.stringify({
          deck: { name: 'Daily Review', word_set_ids: [1], frequency_table_ids: [2] },
        }),
      }),
    )
  })

  it('fetchDeck requests a single deck', async () => {
    const deck = {
      id: 3,
      name: 'Core',
      status: 'processing',
      error_message: null,
      generation_progress: 25,
      generation_total: 40,
      cards_count: 0,
      created_at: '',
      updated_at: '',
    }

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(deck),
      }),
    )

    await expect(fetchDeck(3)).resolves.toEqual(deck)
    expect(fetch).toHaveBeenCalledWith('/api/v1/decks/3', expect.objectContaining({ method: 'GET' }))
  })

  it('fetchFrequencyTables requests the public frequency table index', async () => {
    const tables = [{ id: 1, name: 'jpdb', created_at: '', updated_at: '' }]

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(tables),
      }),
    )

    await expect(fetchFrequencyTables()).resolves.toEqual(tables)
    expect(fetch).toHaveBeenCalledWith(
      '/api/v1/frequency_tables',
      expect.objectContaining({ method: 'GET' }),
    )
  })
})
