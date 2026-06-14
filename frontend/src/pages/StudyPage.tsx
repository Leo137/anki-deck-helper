import { useCallback, useEffect, useRef, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { fetchDeck, fetchStudyCard, recordStudyResponse } from '../api/decks'
import DeckCardHtmlContent from '../components/DeckCardHtmlContent'
import { themeClasses } from '../styles/theme'
import type { DeckCardField, StudyCard } from '../types/deck'

const STUDY_TIMER_MS = 10_000
const TIMER_TICK_MS = 50

const primaryButtonClass =
  'rounded-lg bg-primary px-4 py-2 text-sm font-medium text-on-primary hover:bg-primary-hover disabled:cursor-not-allowed disabled:opacity-60'
const secondaryButtonClass =
  'rounded-lg border border-border-input bg-elevated px-4 py-2 text-sm font-medium text-secondary hover:bg-hover disabled:cursor-not-allowed disabled:opacity-60'

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

export default function StudyPage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const deckId = Number(id)

  const [deckName, setDeckName] = useState<string | null>(null)
  const [card, setCard] = useState<StudyCard | null>(null)
  const [revealed, setRevealed] = useState(false)
  const [timerProgress, setTimerProgress] = useState(0)
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const timerStartRef = useRef<number | null>(null)
  const timerIntervalRef = useRef<ReturnType<typeof setInterval> | null>(null)

  const clearTimer = useCallback(() => {
    if (timerIntervalRef.current) {
      clearInterval(timerIntervalRef.current)
      timerIntervalRef.current = null
    }
    timerStartRef.current = null
  }, [])

  const revealResponse = useCallback(() => {
    clearTimer()
    setTimerProgress(1)
    setRevealed(true)
  }, [clearTimer])

  const startTimer = useCallback(() => {
    clearTimer()
    setTimerProgress(0)
    timerStartRef.current = Date.now()

    timerIntervalRef.current = setInterval(() => {
      if (timerStartRef.current === null) {
        return
      }

      const elapsed = Date.now() - timerStartRef.current
      const progress = Math.min(elapsed / STUDY_TIMER_MS, 1)
      setTimerProgress(progress)

      if (progress >= 1) {
        revealResponse()
      }
    }, TIMER_TICK_MS)
  }, [clearTimer, revealResponse])

  const loadCard = useCallback(
    async (excludeCardId?: number) => {
      if (!deckId) {
        return
      }

      setLoading(true)
      setError(null)
      setRevealed(false)

      try {
        const nextCard = await fetchStudyCard(deckId, excludeCardId)
        setCard(nextCard)
        startTimer()
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load study card')
      } finally {
        setLoading(false)
      }
    },
    [deckId, startTimer],
  )

  useEffect(() => {
    if (!deckId) {
      return
    }

    setLoading(true)
    setError(null)

    fetchDeck(deckId)
      .then((deck) => {
        setDeckName(deck.name)
        if (deck.status !== 'ready' || deck.cards_count === 0) {
          throw new Error('This deck is not ready for study yet.')
        }
        return loadCard()
      })
      .catch((err: Error) => {
        setError(err.message)
        setLoading(false)
      })
  }, [deckId, loadCard])

  useEffect(() => () => clearTimer(), [clearTimer])

  const handleAnswer = useCallback(
    async (correct: boolean) => {
      if (!card || submitting) {
        return
      }

      setSubmitting(true)
      setError(null)

      try {
        await recordStudyResponse(deckId, { card_id: card.id, correct })
        await loadCard(card.id)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to save response')
      } finally {
        setSubmitting(false)
      }
    },
    [card, deckId, loadCard, submitting],
  )

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (isEditableTarget(event.target) || !card || submitting || loading) {
        return
      }

      if (event.key === ' ' || event.code === 'Space') {
        event.preventDefault()
        if (!revealed) {
          revealResponse()
        } else {
          void handleAnswer(true)
        }
        return
      }

      if (!revealed) {
        return
      }

      if (event.key === '1') {
        event.preventDefault()
        void handleAnswer(false)
        return
      }

      if (event.key === '3') {
        event.preventDefault()
        void handleAnswer(true)
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [card, submitting, loading, revealed, revealResponse, handleAnswer])

  const endStudy = () => {
    clearTimer()
    navigate(`/decks/${deckId}`)
  }

  if (loading && !card) {
    return <p className="text-muted">Loading study session…</p>
  }

  if (error && !card) {
    return (
      <div>
        <Link to={`/decks/${deckId}`} className={themeClasses.linkSm}>
          ← Back to deck
        </Link>
        <div className={`mt-4 ${themeClasses.alertError}`}>{error}</div>
      </div>
    )
  }

  if (!card) {
    return null
  }

  const frontField = fieldForSide(card.fields, 'front')
  const backField = fieldForSide(card.fields, 'back')

  return (
    <div>
      <div className="flex flex-wrap items-center justify-between gap-3">
        <Link to={`/decks/${deckId}`} className={themeClasses.linkSm}>
          ← Back to {deckName ?? 'deck'}
        </Link>
        <button type="button" className={secondaryButtonClass} onClick={endStudy}>
          End Study
        </button>
      </div>

      <div className="mt-4 mb-6">
        <h1 className={themeClasses.headingXl}>Study: {deckName}</h1>
        <p className="mt-1 text-sm text-muted tabular-nums">Card {card.position}</p>
        <p className="mt-1 text-xs text-subtle">
          {revealed ? '1 don\u2019t know · 3 or Space know' : 'Space to show response'}
        </p>
      </div>

      {error ? <div className={`mb-4 ${themeClasses.alertError}`}>{error}</div> : null}

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

      {!revealed ? (
        <div className="mt-6 space-y-4">
          <div>
            <div className="h-1.5 overflow-hidden rounded-full bg-subtle-bg">
              <div
                className="h-full rounded-full bg-primary transition-[width] duration-75 ease-linear"
                style={{ width: `${timerProgress * 100}%` }}
                role="progressbar"
                aria-valuenow={Math.round(timerProgress * 100)}
                aria-valuemin={0}
                aria-valuemax={100}
                aria-label="Time until response is shown"
              />
            </div>
            <p className="mt-2 text-xs text-subtle tabular-nums">
              Response reveals in {Math.max(0, Math.ceil((1 - timerProgress) * STUDY_TIMER_MS / 1000))}s
            </p>
          </div>
          <button type="button" className={primaryButtonClass} onClick={revealResponse}>
            Show Response
          </button>
        </div>
      ) : (
        <div className="mt-6 space-y-4">
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

          <div className="flex flex-wrap gap-3">
            <button
              type="button"
              className={secondaryButtonClass}
              disabled={submitting}
              onClick={() => handleAnswer(false)}
            >
              Don&apos;t Know
            </button>
            <button
              type="button"
              className={primaryButtonClass}
              disabled={submitting}
              onClick={() => handleAnswer(true)}
            >
              Know
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
