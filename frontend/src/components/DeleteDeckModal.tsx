import { themeClasses } from '../styles/theme'
import type { DeckSummary } from '../types/deck'

type DeleteDeckModalProps = {
  deck: DeckSummary
  confirming: boolean
  onCancel: () => void
  onConfirm: () => void
}

function isGenerating(deck: DeckSummary) {
  return deck.status === 'pending' || deck.status === 'processing'
}

export default function DeleteDeckModal({ deck, confirming, onCancel, onConfirm }: DeleteDeckModalProps) {
  const generating = isGenerating(deck)
  const title = generating ? 'Cancel deck generation?' : 'Delete deck?'
  const message = generating
    ? `This will stop generating "${deck.name}" and remove the deck permanently.`
    : `This will permanently delete "${deck.name}" and all of its cards.`

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4" role="presentation">
      <div
        className={`w-full max-w-md ${themeClasses.cardPadded}`}
        role="dialog"
        aria-modal="true"
        aria-labelledby="delete-deck-modal-title"
      >
        <h2 id="delete-deck-modal-title" className={themeClasses.headingLg}>
          {title}
        </h2>
        <p className="mt-2 text-sm text-muted">{message}</p>

        <div className="mt-6 flex justify-end gap-3">
          <button
            type="button"
            onClick={onCancel}
            disabled={confirming}
            className="rounded-lg border border-border-input bg-elevated px-4 py-2 text-sm text-secondary transition hover:bg-hover disabled:cursor-not-allowed disabled:opacity-50"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={confirming}
            className="rounded-lg border border-error-border bg-error-bg px-4 py-2 text-sm font-medium text-error-foreground transition hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-50"
          >
            {confirming ? 'Removing…' : generating ? 'Cancel and delete' : 'Delete deck'}
          </button>
        </div>
      </div>
    </div>
  )
}
