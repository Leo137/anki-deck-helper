import { afterEach, describe, expect, it, vi } from 'vitest'
import {
  createDeck,
  downloadDeckAnkiExport,
  fetchDecks,
  fetchDeck,
  fetchDeckCards,
  fetchFrequencyTables,
  fetchStudyCard,
  recordStudyResponse,
} from './decks'

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

  it('fetchDeck requests a single deck with study summary', async () => {
    const deck = {
      id: 3,
      name: 'Core',
      status: 'processing',
      error_message: null,
      generation_progress: 25,
      generation_total: 40,
      cards_count: 2,
      created_at: '',
      updated_at: '',
      study_summary: {
        not_reviewed_count: 1,
        young_count: 1,
        learning_count: 0,
        mature_count: 0,
      },
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

  it('fetchDeckCards includes the search query when provided', async () => {
    const response = {
      cards: [],
      pagination: {
        page: 1,
        per_page: 50,
        total_count: 0,
        total_pages: 0,
      },
    }

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(response),
      }),
    )

    await expect(fetchDeckCards(3, 1, 50, '型')).resolves.toEqual(response)
    expect(fetch).toHaveBeenCalledWith(
      '/api/v1/decks/3/cards?page=1&per_page=50&q=%E5%9E%8B',
      expect.objectContaining({ method: 'GET' }),
    )
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

  it('fetchStudyCard requests the next study card', async () => {
    const card = {
      id: 4,
      position: 1,
      created_at: '',
      updated_at: '',
      deck: { id: 2, name: 'Core' },
      fields: [],
    }

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(card),
      }),
    )

    await expect(fetchStudyCard(2, 3)).resolves.toEqual(card)
    expect(fetch).toHaveBeenCalledWith(
      '/api/v1/decks/2/study/next?exclude_card_id=3',
      expect.objectContaining({ method: 'GET' }),
    )
  })

  it('recordStudyResponse posts a study answer', async () => {
    const stats = {
      know_count: 2,
      dont_know_count: 1,
      total_responses: 3,
      accuracy_rate: 0.667,
      last_responded_at: '2026-06-14T12:00:00Z',
      last_correct: true,
    }

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        status: 201,
        json: () => Promise.resolve(stats),
      }),
    )

    await expect(recordStudyResponse(2, { card_id: 4, correct: true })).resolves.toEqual(stats)
    expect(fetch).toHaveBeenCalledWith(
      '/api/v1/decks/2/study/responses',
      expect.objectContaining({
        method: 'POST',
        body: JSON.stringify({ response: { card_id: 4, correct: true } }),
      }),
    )
  })

  it('downloadDeckAnkiExport downloads the Anki export file', async () => {
    const blob = new Blob(['#front|back\n<h1>test</h1>|<p>answer</p>'], { type: 'text/plain' })
    const click = vi.fn()
    const createObjectURL = vi.fn().mockReturnValue('blob:export')
    const revokeObjectURL = vi.fn()

    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        blob: () => Promise.resolve(blob),
      }),
    )
    vi.stubGlobal('URL', { createObjectURL, revokeObjectURL })
    vi.spyOn(document, 'createElement').mockReturnValue({
      click,
      download: '',
      href: '',
    } as unknown as HTMLAnchorElement)

    await downloadDeckAnkiExport(3, 'Core Vocab')

    expect(fetch).toHaveBeenCalledWith(
      '/api/v1/decks/3/anki_export',
      expect.objectContaining({ headers: expect.any(Headers) }),
    )
    expect(createObjectURL).toHaveBeenCalledWith(blob)
    expect(click).toHaveBeenCalled()
    expect(revokeObjectURL).toHaveBeenCalledWith('blob:export')
  })
})
