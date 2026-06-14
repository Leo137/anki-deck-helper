import { request } from './client'
import type {
  CreateDeckPayload,
  DeckCardDetail,
  DeckSummary,
  FrequencyTableSummary,
  PaginatedDeckCards,
} from '../types/deck'

export function fetchDecks(): Promise<DeckSummary[]> {
  return request('/api/v1/decks')
}

export function fetchDeck(id: number): Promise<DeckSummary> {
  return request(`/api/v1/decks/${id}`)
}

export function fetchDeckCards(deckId: number, page = 1, perPage = 50): Promise<PaginatedDeckCards> {
  const params = new URLSearchParams({
    page: String(page),
    per_page: String(perPage),
  })
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
