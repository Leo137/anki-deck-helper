import { useEffect, useState } from 'react'
import { Link, useParams, useSearchParams } from 'react-router-dom'
import { fetchDeck, fetchDeckCards } from '../api/decks'
import DeckCardTable from '../components/DeckCardTable'
import PaginationControls from '../components/PaginationControls'
import { themeClasses } from '../styles/theme'
import type { DeckCardSummary, DeckSummary } from '../types/deck'
import type { Pagination } from '../types/word'

const statusLabels: Record<DeckSummary['status'], string> = {
  pending: 'Queued',
  processing: 'Generating',
  ready: 'Ready',
  failed: 'Failed',
}

export default function DeckPage() {
  const { id } = useParams<{ id: string }>()
  const [searchParams, setSearchParams] = useSearchParams()
  const page = Math.max(Number(searchParams.get('page') ?? '1'), 1)

  const [deck, setDeck] = useState<DeckSummary | null>(null)
  const [cards, setCards] = useState<DeckCardSummary[]>([])
  const [pagination, setPagination] = useState<Pagination | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!id) return

    setLoading(true)
    setError(null)

    Promise.all([fetchDeck(Number(id)), fetchDeckCards(Number(id), page)])
      .then(([deckData, cardsData]) => {
        setDeck(deckData)
        setCards(cardsData.cards)
        setPagination(cardsData.pagination)
      })
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false))
  }, [id, page])

  const handlePageChange = (nextPage: number) => {
    setSearchParams(nextPage > 1 ? { page: String(nextPage) } : {})
  }

  if (loading) {
    return <p className="text-muted">Loading deck…</p>
  }

  if (error || !deck) {
    return (
      <div>
        <Link to="/decks" className={themeClasses.linkSm}>
          ← Back to decks
        </Link>
        <div className={`mt-4 ${themeClasses.alertError}`}>{error ?? 'Deck not found'}</div>
      </div>
    )
  }

  return (
    <div>
      <Link to="/decks" className={themeClasses.linkSm}>
        ← Back to decks
      </Link>
      <div className="mt-4 mb-6">
        <div className="flex flex-wrap items-center gap-3">
          <h1 className={themeClasses.headingXl}>{deck.name}</h1>
          <span className={themeClasses.badge}>{statusLabels[deck.status]}</span>
        </div>
        <p className="mt-1 text-muted">
          {deck.cards_count.toLocaleString()} {deck.cards_count === 1 ? 'card' : 'cards'}
        </p>
        {deck.status === 'failed' && deck.error_message ? (
          <p className="mt-2 text-sm text-error-foreground">{deck.error_message}</p>
        ) : null}
      </div>
      <DeckCardTable cards={cards} deckId={deck.id} page={page} />
      {pagination && (
        <PaginationControls pagination={pagination} onPageChange={handlePageChange} />
      )}
    </div>
  )
}
