import { Link } from 'react-router-dom'
import { themeClasses } from '../styles/theme'
import type { WordSetSummary } from '../types/word'

type WordSetListProps = {
  wordSets: WordSetSummary[]
}

export default function WordSetList({ wordSets }: WordSetListProps) {
  if (wordSets.length === 0) {
    return (
      <p className={`${themeClasses.cardDashed} px-6 py-12 text-center text-muted`}>
        No word sets yet. Import lists via the Rails console to get started.
      </p>
    )
  }

  return (
    <ul className="grid gap-4 sm:grid-cols-2">
      {wordSets.map((wordSet) => (
        <li key={wordSet.id}>
          <Link to={`/word-sets/${wordSet.id}`} className={themeClasses.wordSetCard}>
            <h2 className={themeClasses.headingLg}>{wordSet.name}</h2>
            <p className="mt-1 text-sm text-muted">
              {wordSet.words_count.toLocaleString()} {wordSet.words_count === 1 ? 'word' : 'words'}
            </p>
          </Link>
        </li>
      ))}
    </ul>
  )
}
