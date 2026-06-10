import { useEffect, useState } from 'react'
import { Link, useLocation, useParams } from 'react-router-dom'
import { fetchWord, type WordDetail } from '../api/words'
import DictionaryEntryCard from '../components/DictionaryEntryCard'
import { themeClasses } from '../styles/theme'
import type { WordDetailLocationState } from '../types/word'

function backLink(state: WordDetailLocationState | null) {
  if (state?.wordSetId) {
    const pageQuery = state.page && state.page > 1 ? `?page=${state.page}` : ''
    return {
      to: `/word-sets/${state.wordSetId}${pageQuery}`,
      label: '← Back to word set',
    }
  }

  return { to: '/', label: '← Back to word sets' }
}

export default function WordDetailPage() {
  const { id } = useParams<{ id: string }>()
  const location = useLocation()
  const navigationState = location.state as WordDetailLocationState | null
  const back = backLink(navigationState)

  const [word, setWord] = useState<WordDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!id) return

    fetchWord(Number(id))
      .then(setWord)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false))
  }, [id])

  if (loading) {
    return <p className="text-muted">Loading word…</p>
  }

  if (error || !word) {
    return (
      <div>
        <Link to={back.to} className={themeClasses.linkSm}>
          {back.label}
        </Link>
        <div className={`mt-4 ${themeClasses.alertError}`}>{error ?? 'Word not found'}</div>
      </div>
    )
  }

  return (
    <div>
      <Link to={back.to} className={themeClasses.linkSm}>
        {back.label}
      </Link>

      <div className="mt-4 space-y-4">
        {word.dictionary_entries.length > 0 ? (
          word.dictionary_entries.map((entry, index) => (
            <DictionaryEntryCard key={`${entry.text}-${index}`} entry={entry} fallbackWord={word.content} />
          ))
        ) : (
          <div className={`${themeClasses.cardPadded} text-center`}>
            <h2 className={themeClasses.heading2xl}>{word.content}</h2>
            {(word.reading ?? word.kana) && (
              <p className="mt-2 text-xl text-muted">{word.reading ?? word.kana}</p>
            )}
            <p className="mt-4 text-sm text-muted">No dictionary entry found for this word.</p>
          </div>
        )}
      </div>

      <div className={`mt-6 ${themeClasses.panel}`}>
        <dl className="grid gap-4 sm:grid-cols-2">
          <div>
            <dt className="text-xs font-medium uppercase tracking-wide text-muted">Occurrences</dt>
            <dd className="mt-1 text-lg tabular-nums">{word.word_count}</dd>
          </div>
          <div>
            <dt className="text-xs font-medium uppercase tracking-wide text-muted">Tags</dt>
            <dd className="mt-1 flex flex-wrap gap-1">
              {word.tags.length === 0 ? (
                <span className="text-muted">None</span>
              ) : (
                word.tags.map((tag) => (
                  <span key={tag} className={themeClasses.tagSm}>
                    {tag}
                  </span>
                ))
              )}
            </dd>
          </div>
        </dl>

        {word.frequencies.length > 0 && (
          <div className="mt-6">
            <h2 className="text-sm font-medium uppercase tracking-wide text-muted">Frequencies</h2>
            <ul className={`mt-2 ${themeClasses.listPanel}`}>
              {word.frequencies.map((entry) => (
                <li
                  key={entry.table}
                  className="flex items-center justify-between px-4 py-2 text-sm"
                >
                  <span className={themeClasses.listItemLabel}>{entry.table}</span>
                  <span className="tabular-nums text-muted">
                    {entry.frequency.toLocaleString()} ({(entry.ratio * 100).toFixed(2)}%)
                  </span>
                </li>
              ))}
            </ul>
          </div>
        )}

        {word.word_sets.length > 0 && (
          <div className="mt-6">
            <h2 className="text-sm font-medium uppercase tracking-wide text-muted">Word sets</h2>
            <ul className="mt-2 flex flex-wrap gap-2">
              {word.word_sets.map((wordSet) => (
                <li key={wordSet.id}>
                  <Link to={`/word-sets/${wordSet.id}`} className={themeClasses.wordSetPill}>
                    {wordSet.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </div>
  )
}
