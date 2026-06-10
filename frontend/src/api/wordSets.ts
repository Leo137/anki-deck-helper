import { request } from './client'
import type { PaginatedWords, WordSetDetail, WordSetSummary } from '../types/word'

export function fetchWordSets(): Promise<WordSetSummary[]> {
  return request('/api/v1/word_sets')
}

export function fetchWordSet(id: number): Promise<WordSetDetail> {
  return request(`/api/v1/word_sets/${id}`)
}

export function fetchWordSetWords(
  wordSetId: number,
  page = 1,
  perPage = 50,
): Promise<PaginatedWords> {
  const params = new URLSearchParams({
    page: String(page),
    per_page: String(perPage),
  })
  return request(`/api/v1/word_sets/${wordSetId}/words?${params}`)
}
