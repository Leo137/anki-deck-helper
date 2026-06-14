import { Link } from 'react-router-dom'
import { themeClasses } from '../styles/theme'
import type { DeckStatus, DeckSummary } from '../types/deck'
import TrashIcon from './icons/TrashIcon'

type DeckListProps = {
  decks: DeckSummary[]
  deletingId?: number | null
  onDelete: (deck: DeckSummary) => void
}

const statusLabels: Record<DeckStatus, string> = {
  pending: 'Queued',
  processing: 'Generating',
  ready: 'Ready',
  failed: 'Failed',
}

function isGenerating(deck: DeckSummary) {
  return deck.status === 'pending' || deck.status === 'processing'
}

function completedCards(deck: DeckSummary) {
  if (!deck.generation_total) return 0
  return Math.round((deck.generation_progress / 100) * deck.generation_total)
}

function deleteActionLabel(deck: DeckSummary) {
  return isGenerating(deck) ? 'Cancel' : 'Delete'
}

export default function DeckList({ decks, deletingId = null, onDelete }: DeckListProps) {
  if (decks.length === 0) {
    return (
      <p className={`${themeClasses.cardDashed} px-6 py-12 text-center text-muted`}>
        No decks yet. Use Create deck to build your first one.
      </p>
    )
  }

  return (
    <ul className="grid gap-4 sm:grid-cols-2">
      {decks.map((deck) => {
        const isDeleting = deletingId === deck.id

        return (
          <li key={deck.id}>
            <div className={themeClasses.wordSetCard}>
              <div className="flex items-start justify-between gap-3">
                <Link to={`/decks/${deck.id}`} className="min-w-0 flex-1">
                  <h2 className={themeClasses.headingLg}>{deck.name}</h2>
                </Link>
                <div className="flex shrink-0 items-center gap-2">
                  <span className={themeClasses.badge}>{statusLabels[deck.status]}</span>
                  <button
                    type="button"
                    className={`${themeClasses.iconButton} text-muted hover:text-error-foreground disabled:cursor-not-allowed disabled:opacity-50`}
                    onClick={() => onDelete(deck)}
                    disabled={isDeleting}
                    aria-label={`${deleteActionLabel(deck)} deck ${deck.name}`}
                  >
                    <TrashIcon />
                  </button>
                </div>
              </div>

              <Link to={`/decks/${deck.id}`} className="mt-1 block">
                {isGenerating(deck) ? (
                  <div className="mt-3">
                    <div className="mb-1 flex items-center justify-between text-xs text-muted">
                      <span>
                        {deck.generation_total
                          ? `${completedCards(deck).toLocaleString()} / ${deck.generation_total.toLocaleString()} cards`
                          : 'Preparing…'}
                      </span>
                      <span>{deck.generation_progress}%</span>
                    </div>
                    <div
                      className="h-2 overflow-hidden rounded-full bg-subtle-bg"
                      role="progressbar"
                      aria-valuenow={deck.generation_progress}
                      aria-valuemin={0}
                      aria-valuemax={100}
                      aria-label={`${deck.name} generation progress`}
                    >
                      <div
                        className="h-full rounded-full bg-primary transition-[width] duration-300 ease-out"
                        style={{ width: `${deck.generation_progress}%` }}
                      />
                    </div>
                  </div>
                ) : (
                  <p className="text-sm text-muted">
                    {deck.cards_count.toLocaleString()} {deck.cards_count === 1 ? 'card' : 'cards'}
                  </p>
                )}

                {deck.status === 'failed' && deck.error_message ? (
                  <p className="mt-2 text-sm text-error-foreground">{deck.error_message}</p>
                ) : null}
              </Link>
            </div>
          </li>
        )
      })}
    </ul>
  )
}
