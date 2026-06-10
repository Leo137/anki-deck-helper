export type SearchWord = {
  id: number
  content: string
  reading: string | null
}

export type SearchWordSet = {
  id: number
  name: string
  words_count: number
}

export type SearchResults = {
  query: string
  words: SearchWord[]
  word_sets: SearchWordSet[]
}
