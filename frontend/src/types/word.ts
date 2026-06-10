export type Tag = string

export type Frequency = {
  table: string
  frequency: number
  ratio: number
}

export type Word = {
  id: number
  content: string
  kana: string | null
  reading: string | null
  word_count: number
  tags: Tag[]
  frequencies: Frequency[]
}

export type Pagination = {
  page: number
  per_page: number
  total_count: number
  total_pages: number
}

export type PaginatedWords = {
  words: Word[]
  pagination: Pagination
}

export type WordSetSummary = {
  id: number
  name: string
  words_count: number
  created_at: string
  updated_at: string
}

export type WordSetDetail = WordSetSummary

export type DictionarySense = {
  tags: string[]
  definitions: string[]
}

export type DictionaryEntry = {
  text: string
  readings: string[]
  senses: DictionarySense[]
}

export type WordDetailLocationState = {
  wordSetId?: number
  page?: number
}
