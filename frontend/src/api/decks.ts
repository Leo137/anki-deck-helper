import { request } from './client'
import type { DeckSummary } from '../types/deck'

export function fetchDecks(): Promise<DeckSummary[]> {
  return request('/api/v1/decks')
}
