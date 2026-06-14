import { useEffect, useRef, useState } from 'react'
import { Link, useParams, useSearchParams } from 'react-router-dom'
import { fetchDeck, fetchDeckCards } from '../api/decks'
import DeckCardTable from '../components/DeckCardTable'
import PaginationControls from '../components/PaginationControls'
import { useDebouncedValue } from '../hooks/useDebouncedValue'
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
  const [searchInput, setSearchInput] = useState(() => searchParams.get('q') ?? '')
  const isComposingRef = useRef(false)
  const debouncedInput = useDebouncedValue(searchInput, 300)
  const [activeQuery, setActiveQuery] = useState(() => (searchParams.get('q') ?? '').trim())
  const previousQueryRef = useRef(activeQuery)
  const fetchPage = previousQueryRef.current !== activeQuery ? 1 : page
  const skipCardsRefetchRef = useRef(true)

  const [deck, setDeck] = useState<DeckSummary | null>(null)
  const [cards, setCards] = useState<DeckCardSummary[]>([])
  const [pagination, setPagination] = useState<Pagination | null>(null)
  const [initialLoading, setInitialLoading] = useState(true)
  const [cardsLoading, setCardsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (isComposingRef.current) return
    setActiveQuery(debouncedInput.trim())
  }, [debouncedInput])

  useEffect(() => {
    if (!id) return

    let cancelled = false
    setInitialLoading(true)
    setError(null)
    skipCardsRefetchRef.current = true

    const deckId = Number(id)
    const initialPage = Math.max(Number(searchParams.get('page') ?? '1'), 1)
    const initialQuery = (searchParams.get('q') ?? '').trim()

    Promise.all([
      fetchDeck(deckId),
      fetchDeckCards(deckId, initialPage, 50, initialQuery || undefined),
    ])
      .then(([deckData, cardsData]) => {
        if (cancelled) return
        setDeck(deckData)
        setCards(cardsData.cards)
        setPagination(cardsData.pagination)
      })
      .catch((err: Error) => {
        if (!cancelled) setError(err.message)
      })
      .finally(() => {
        if (!cancelled) setInitialLoading(false)
      })

    return () => {
      cancelled = true
    }
  }, [id])

  useEffect(() => {
    if (!id || !deck || initialLoading) return
    if (skipCardsRefetchRef.current) {
      skipCardsRefetchRef.current = false
      return
    }

    let cancelled = false
    setCardsLoading(true)

    fetchDeckCards(Number(id), fetchPage, 50, activeQuery || undefined)
      .then((cardsData) => {
        if (cancelled) return
        setCards(cardsData.cards)
        setPagination(cardsData.pagination)
      })
      .catch((err: Error) => {
        if (!cancelled) setError(err.message)
      })
      .finally(() => {
        if (!cancelled) setCardsLoading(false)
      })

    return () => {
      cancelled = true
    }
  }, [id, deck, fetchPage, activeQuery, initialLoading])

  useEffect(() => {
    previousQueryRef.current = activeQuery
  }, [activeQuery])

  useEffect(() => {
    const params = new URLSearchParams()
    if (activeQuery) {
      params.set('q', activeQuery)
    }

    const queryInUrl = searchParams.get('q') ?? ''
    if (activeQuery !== queryInUrl) {
      setSearchParams(params, { replace: true })
      return
    }

    if (page > 1) {
      params.set('page', String(page))
    }
    if (params.toString() !== searchParams.toString()) {
      setSearchParams(params, { replace: true })
    }
  }, [activeQuery, page, searchParams, setSearchParams])

  const handlePageChange = (nextPage: number) => {
    const params = new URLSearchParams()
    if (activeQuery) {
      params.set('q', activeQuery)
    }
    if (nextPage > 1) {
      params.set('page', String(nextPage))
    }
    setSearchParams(params)
  }

  if (initialLoading) {
    return <p className="text-muted">Loading deck…</p>
  }

  if (error && !deck) {
    return (
      <div>
        <Link to="/decks" className={themeClasses.linkSm}>
          ← Back to decks
        </Link>
        <div className={`mt-4 ${themeClasses.alertError}`}>{error}</div>
      </div>
    )
  }

  if (!deck) {
    return (
      <div>
        <Link to="/decks" className={themeClasses.linkSm}>
          ← Back to decks
        </Link>
        <div className={`mt-4 ${themeClasses.alertError}`}>Deck not found</div>
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
        {deck.status === 'ready' && deck.cards_count > 0 ? (
          <Link
            to={`/decks/${deck.id}/study`}
            className="mt-4 inline-block rounded-lg bg-primary px-4 py-2 text-sm font-medium text-on-primary hover:bg-primary-hover"
          >
            Study
          </Link>
        ) : null}
        {deck.status === 'failed' && deck.error_message ? (
          <p className="mt-2 text-sm text-error-foreground">{deck.error_message}</p>
        ) : null}
      </div>
      {deck.study_summary && deck.cards_count > 0 ? (
        <div className={`mb-6 ${themeClasses.panel}`}>
          <h2 className="text-sm font-medium uppercase tracking-wide text-muted">
            Study progress
          </h2>
          <dl className="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <div>
              <dt className="text-xs font-medium uppercase tracking-wide text-muted">
                Not reviewed
              </dt>
              <dd className="mt-1 text-lg tabular-nums">
                {deck.study_summary.not_reviewed_count.toLocaleString()}
              </dd>
            </div>
            <div>
              <dt className="text-xs font-medium uppercase tracking-wide text-muted">Young</dt>
              <dd className="mt-1 text-lg tabular-nums">
                {deck.study_summary.young_count.toLocaleString()}
              </dd>
            </div>
            <div>
              <dt className="text-xs font-medium uppercase tracking-wide text-muted">
                Learning
              </dt>
              <dd className="mt-1 text-lg tabular-nums">
                {deck.study_summary.learning_count.toLocaleString()}
              </dd>
            </div>
            <div>
              <dt className="text-xs font-medium uppercase tracking-wide text-muted">Mature</dt>
              <dd className="mt-1 text-lg tabular-nums">
                {deck.study_summary.mature_count.toLocaleString()}
              </dd>
            </div>
          </dl>
        </div>
      ) : null}
      <div className="mb-4">
        <label htmlFor="deck-card-search" className="sr-only">
          Search cards
        </label>
        <input
          id="deck-card-search"
          type="text"
          value={searchInput}
          onChange={(event) => setSearchInput(event.target.value)}
          onCompositionStart={() => {
            isComposingRef.current = true
          }}
          onCompositionEnd={(event) => {
            isComposingRef.current = false
            const value = event.currentTarget.value
            setSearchInput(value)
            setActiveQuery(value.trim())
          }}
          placeholder="Search cards…"
          autoComplete="off"
          autoCorrect="off"
          spellCheck={false}
          lang="ja"
          className={themeClasses.input}
        />
        {cardsLoading ? (
          <p className="mt-2 text-xs text-subtle" aria-live="polite">
            Searching…
          </p>
        ) : null}
      </div>
      <div className={cardsLoading ? 'opacity-60 transition-opacity' : 'transition-opacity'}>
        <DeckCardTable
          cards={cards}
          deckId={deck.id}
          page={page}
          searchQuery={activeQuery || undefined}
        />
        {pagination && (
          <PaginationControls pagination={pagination} onPageChange={handlePageChange} />
        )}
      </div>
    </div>
  )
}
