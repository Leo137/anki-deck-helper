import { request } from './client'
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
