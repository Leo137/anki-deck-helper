import { Link } from 'react-router-dom'
import type { WordSetSummary } from '../types/word'

type WordSetListProps = {
  wordSets: WordSetSummary[]
}

export default function WordSetList({ wordSets }: WordSetListProps) {
  if (wordSets.length === 0) {
    return (
      <p className="rounded-lg border border-dashed border-gray-300 bg-elevated px-6 py-12 text-center text-muted dark:border-gray-600">
        No word sets yet. Import lists via the Rails console to get started.
      </p>
    )
  }

  return (
    <ul className="grid gap-4 sm:grid-cols-2">
      {wordSets.map((wordSet) => (
        <li key={wordSet.id}>
          <Link
            to={`/word-sets/${wordSet.id}`}
            className="block rounded-lg border border-gray-200 bg-elevated p-5 shadow-sm transition hover:border-primary hover:shadow-md dark:border-gray-700 dark:hover:border-primary"
          >
            <h2 className="text-lg font-medium text-gray-900 dark:text-gray-100">{wordSet.name}</h2>
            <p className="mt-1 text-sm text-muted">
              {wordSet.words_count.toLocaleString()} {wordSet.words_count === 1 ? 'word' : 'words'}
            </p>
          </Link>
        </li>
      ))}
    </ul>
  )
}
