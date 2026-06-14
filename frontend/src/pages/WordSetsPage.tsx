import { useEffect, useState } from 'react'
import { fetchWordSets } from '../api/wordSets'
import WordSetList from '../components/WordSetList'
import { themeClasses } from '../styles/theme'
import type { WordSetSummary } from '../types/word'

export default function WordSetsPage() {
  const [wordSets, setWordSets] = useState<WordSetSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchWordSets()
      .then(setWordSets)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) {
    return <p className="text-muted">Loading word sets…</p>
  }

  if (error) {
    return (
      <div className={themeClasses.alertError}>Failed to load word sets: {error}</div>
    )
  }

  return (
    <div>
      <h1 className={`mb-6 ${themeClasses.headingXl}`}>Word Sets</h1>
      <WordSetList wordSets={wordSets} />
    </div>
  )
}
