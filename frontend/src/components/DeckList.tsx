import { themeClasses } from '../styles/theme'
import type { DeckSummary } from '../types/deck'

type DeckListProps = {
  decks: DeckSummary[]
}

export default function DeckList({ decks }: DeckListProps) {
  if (decks.length === 0) {
    return (
      <p className={`${themeClasses.cardDashed} px-6 py-12 text-center text-muted`}>
        No decks yet. Deck creation will be available in a future update.
      </p>
    )
  }

  return (
    <ul className="grid gap-4 sm:grid-cols-2">
      {decks.map((deck) => (
        <li key={deck.id}>
          <div className={themeClasses.wordSetCard}>
            <h2 className={themeClasses.headingLg}>{deck.name}</h2>
            <p className="mt-1 text-sm text-muted">
              {deck.words_count.toLocaleString()} {deck.words_count === 1 ? 'word' : 'words'}
            </p>
          </div>
        </li>
      ))}
    </ul>
  )
}
