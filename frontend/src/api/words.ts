import { request } from './client'
import type { Word, DictionaryEntry } from '../types/word'

type WordDetail = Word & {
  word_sets: { id: number; name: string }[]
  dictionary_entries: DictionaryEntry[]
  available_languages: string[]
}

export function fetchWord(id: number, language = 'en'): Promise<WordDetail> {
  const params = new URLSearchParams({ language })
  return request(`/api/v1/words/${id}?${params}`)
}

export type { WordDetail }
