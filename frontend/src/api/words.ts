import { request } from './client'
import type { Word, DictionaryEntry } from '../types/word'

type WordDetail = Word & {
  word_sets: { id: number; name: string }[]
  dictionary_entries: DictionaryEntry[]
}

export function fetchWord(id: number): Promise<WordDetail> {
  return request(`/api/v1/words/${id}`)
}

export type { WordDetail }
