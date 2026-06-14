export type DeckStatus = 'pending' | 'processing' | 'ready' | 'failed'

export type DeckCardFieldSide = 'front' | 'back'

export type DeckCardField = {
  id: number
  side: DeckCardFieldSide
  html_content: string
  created_at: string
  updated_at: string
}

export type DeckCardSummary = {
  id: number
  position: number
  front_preview: string
  created_at: string
  updated_at: string
}

export type DeckCard = {
  id: number
  position: number
  fields: DeckCardField[]
  created_at: string
  updated_at: string
}

export type DeckCardDetail = DeckCard & {
  previous_card_id: number | null
  next_card_id: number | null
  deck: {
    id: number
    name: string
  }
}

export type PaginatedDeckCards = {
  cards: DeckCardSummary[]
  pagination: {
    page: number
    per_page: number
    total_count: number
    total_pages: number
  }
}

export type DeckSummary = {
  id: number
  name: string
  status: DeckStatus
  error_message: string | null
  generation_progress: number
  generation_total: number | null
  cards_count: number
  created_at: string
  updated_at: string
}

export type FrequencyTableSummary = {
  id: number
  name: string
  created_at: string
  updated_at: string
}

export type CreateDeckPayload = {
  name: string
  word_set_ids: number[]
  frequency_table_ids: number[]
}
