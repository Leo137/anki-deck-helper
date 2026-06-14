import { getAuthToken, request } from './client'
import type {
  CreateDeckPayload,
  DeckCardDetail,
  DeckCardStudyStats,
  DeckSummary,
  FrequencyTableSummary,
  PaginatedDeckCards,
  RecordStudyResponsePayload,
  StudyCard,
} from '../types/deck'

export function fetchDecks(): Promise<DeckSummary[]> {
  return request('/api/v1/decks')
}

export function fetchDeck(id: number): Promise<DeckSummary> {
  return request(`/api/v1/decks/${id}`)
}

export function fetchDeckCards(
  deckId: number,
  page = 1,
  perPage = 50,
  query?: string,
): Promise<PaginatedDeckCards> {
  const params = new URLSearchParams({
    page: String(page),
    per_page: String(perPage),
  })
  const trimmedQuery = query?.trim()
  if (trimmedQuery) {
    params.set('q', trimmedQuery)
  }
  return request(`/api/v1/decks/${deckId}/cards?${params}`)
}

export function fetchDeckCard(deckId: number, cardId: number): Promise<DeckCardDetail> {
  return request(`/api/v1/decks/${deckId}/cards/${cardId}`)
}

export function createDeck(payload: CreateDeckPayload): Promise<DeckSummary> {
  return request('/api/v1/decks', {
    method: 'POST',
    body: { deck: payload },
  })
}

export function deleteDeck(id: number): Promise<void> {
  return request(`/api/v1/decks/${id}`, { method: 'DELETE' })
}

export function fetchFrequencyTables(): Promise<FrequencyTableSummary[]> {
  return request('/api/v1/frequency_tables', { auth: false })
}

export function fetchStudyCard(deckId: number, excludeCardId?: number): Promise<StudyCard> {
  const params = new URLSearchParams()
  if (excludeCardId) {
    params.set('exclude_card_id', String(excludeCardId))
  }
  const query = params.toString()
  const path = query
    ? `/api/v1/decks/${deckId}/study/next?${query}`
    : `/api/v1/decks/${deckId}/study/next`
  return request(path)
}

export function recordStudyResponse(
  deckId: number,
  payload: RecordStudyResponsePayload,
): Promise<DeckCardStudyStats> {
  return request(`/api/v1/decks/${deckId}/study/responses`, {
    method: 'POST',
    body: { response: payload },
  })
}

export async function downloadDeckAnkiExport(deckId: number, deckName: string): Promise<void> {
  const headers = new Headers()
  const token = getAuthToken()
  if (token) {
    headers.set('Authorization', token)
  }

  const response = await fetch(`/api/v1/decks/${deckId}/anki_export`, { headers })

  if (!response.ok) {
    let message = response.status === 404 ? 'Not found' : `Request failed (${response.status})`

    try {
      const errorBody = (await response.json()) as { error?: string; errors?: string[] }
      if (errorBody.errors?.length) {
        message = errorBody.errors.join(', ')
      } else if (errorBody.error) {
        message = errorBody.error
      }
    } catch {
      // Keep the default message when the body is not JSON.
    }

    throw new Error(message)
  }

  const blob = await response.blob()
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `${deckName}.txt`
  link.click()
  URL.revokeObjectURL(url)
}
