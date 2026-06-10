import { useEffect, useState } from 'react'
import { fetchWordSets } from '../api/wordSets'
import WordSetList from '../components/WordSetList'
import type { WordSetSummary } from '../types/word'

export default function HomePage() {
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
      <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-red-700 dark:border-red-900 dark:bg-red-950/50 dark:text-red-300">
        Failed to load word sets: {error}
      </div>
    )
  }

  return (
    <div>
      <h1 className="mb-6 text-2xl font-semibold text-gray-900 dark:text-gray-100">Word Sets</h1>
      <WordSetList wordSets={wordSets} />
    </div>
  )
}
