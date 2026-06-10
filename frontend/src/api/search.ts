import { request } from './client'
import type { SearchResults } from '../types/search'

export function search(query: string): Promise<SearchResults> {
  const params = new URLSearchParams({ q: query })
  return request(`/api/v1/search?${params}`)
}
