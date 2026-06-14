import { useCallback, useEffect, useState } from 'react'
import { Link, useLocation, useNavigate, useParams } from 'react-router-dom'
import { fetchDeckCard } from '../api/decks'
import DeckCardHtmlContent from '../components/DeckCardHtmlContent'
import { ChevronLeftIcon, ChevronRightIcon } from '../components/icons/ChevronIcons'
import { themeClasses } from '../styles/theme'
import type { DeckCardDetail, DeckCardField } from '../types/deck'

export type DeckCardDetailLocationState = {
  deckId?: number
  page?: number
}

function backLink(state: DeckCardDetailLocationState | null, deckId: number, deckName: string) {
  if (state?.deckId) {
    const pageQuery = state.page && state.page > 1 ? `?page=${state.page}` : ''
    return {
      to: `/decks/${state.deckId}${pageQuery}`,
      label: `← Back to ${deckName}`,
    }
  }

  return {
    to: `/decks/${deckId}`,
    label: `← Back to ${deckName}`,
  }
}

function fieldForSide(fields: DeckCardField[], side: DeckCardField['side']) {
  return fields.find((field) => field.side === side)
}

function isEditableTarget(target: EventTarget | null) {
  return (
    target instanceof HTMLInputElement ||
    target instanceof HTMLTextAreaElement ||
    target instanceof HTMLSelectElement ||
    (target instanceof HTMLElement && target.isContentEditable)
  )
}

export default function DeckCardDetailPage() {
  const { deckId, id } = useParams<{ deckId: string; id: string }>()
  const location = useLocation()
  const navigate = useNavigate()
  const navigationState = location.state as DeckCardDetailLocationState | null

  const [card, setCard] = useState<DeckCardDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const goToCard = useCallback(
    (cardId: number) => {
      if (!deckId) {
        return
      }

      navigate(`/decks/${deckId}/cards/${cardId}`, {
        state: navigationState,
      })
    },
    [deckId, navigate, navigationState],
  )

  useEffect(() => {
    if (!deckId || !id) return

    setLoading(true)
    setError(null)

    fetchDeckCard(Number(deckId), Number(id))
      .then(setCard)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false))
  }, [deckId, id])

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (isEditableTarget(event.target) || !card) {
        return
      }

      if (event.key === 'ArrowLeft' && card.previous_card_id) {
        event.preventDefault()
        goToCard(card.previous_card_id)
      }

      if (event.key === 'ArrowRight' && card.next_card_id) {
        event.preventDefault()
        goToCard(card.next_card_id)
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [card, goToCard])

  if (error) {
    return (
      <div>
        <Link to="/decks" className={themeClasses.linkSm}>
          ← Back to decks
        </Link>
        <div className={`mt-4 ${themeClasses.alertError}`}>{error}</div>
      </div>
    )
  }

  if (loading || !card) {
    return <p className="text-muted">Loading card…</p>
  }

  const frontField = fieldForSide(card.fields, 'front')
  const backField = fieldForSide(card.fields, 'back')
  const back = backLink(navigationState, card.deck.id, card.deck.name)

  return (
    <div>
      <Link to={back.to} className={themeClasses.linkSm}>
        {back.label}
      </Link>

      <div className="mt-4 flex items-center justify-between gap-3">
        <button
          type="button"
          className={`${themeClasses.iconButton} disabled:cursor-not-allowed disabled:opacity-40`}
          onClick={() => card.previous_card_id && goToCard(card.previous_card_id)}
          disabled={!card.previous_card_id}
          aria-label="Previous card"
          title="Previous card (← arrow key)"
        >
          <ChevronLeftIcon />
        </button>
        <div className="text-center">
          <p className="text-sm text-muted tabular-nums">Card {card.position}</p>
          <p className="text-xs text-subtle">Use ← → arrow keys</p>
        </div>
        <button
          type="button"
          className={`${themeClasses.iconButton} disabled:cursor-not-allowed disabled:opacity-40`}
          onClick={() => card.next_card_id && goToCard(card.next_card_id)}
          disabled={!card.next_card_id}
          aria-label="Next card"
          title="Next card (→ arrow key)"
        >
          <ChevronRightIcon />
        </button>
      </div>

      <div className="mt-4 space-y-4">
        <section className={themeClasses.cardPadded}>
          <h2 className="text-sm font-medium uppercase tracking-wide text-muted">Front</h2>
          <div className="mt-3">
            {frontField ? (
              <DeckCardHtmlContent html={frontField.html_content} />
            ) : (
              <p className="text-muted">No front content.</p>
            )}
          </div>
        </section>

        <section className={themeClasses.cardPadded}>
          <h2 className="text-sm font-medium uppercase tracking-wide text-muted">Back</h2>
          <div className="mt-3">
            {backField ? (
              <DeckCardHtmlContent html={backField.html_content} />
            ) : (
              <p className="text-muted">No back content.</p>
            )}
          </div>
        </section>
      </div>

      <div className={`mt-6 ${themeClasses.panel}`}>
        <dl className="grid gap-4 sm:grid-cols-2">
          <div>
            <dt className="text-xs font-medium uppercase tracking-wide text-muted">Position</dt>
            <dd className="mt-1 text-lg tabular-nums">{card.position}</dd>
          </div>
          <div>
            <dt className="text-xs font-medium uppercase tracking-wide text-muted">Deck</dt>
            <dd className="mt-1">
              <Link to={`/decks/${card.deck.id}`} className={themeClasses.wordSetPill}>
                {card.deck.name}
              </Link>
            </dd>
          </div>
        </dl>
      </div>
    </div>
  )
}
