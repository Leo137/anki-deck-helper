import { useEffect, useState } from 'react'
import { fetchDecks } from '../api/decks'
import { fetchWordSets } from '../api/wordSets'
import DeckList from '../components/DeckList'
import WordSetList from '../components/WordSetList'
import { useAuth } from '../contexts/AuthContext'
import { themeClasses } from '../styles/theme'
import type { DeckSummary } from '../types/deck'
import type { WordSetSummary } from '../types/word'

export default function HomePage() {
  const { user, loading: authLoading } = useAuth()
  const [wordSets, setWordSets] = useState<WordSetSummary[]>([])
  const [decks, setDecks] = useState<DeckSummary[]>([])
  const [loadingWordSets, setLoadingWordSets] = useState(true)
  const [loadingDecks, setLoadingDecks] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchWordSets()
      .then(setWordSets)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoadingWordSets(false))
  }, [])

  useEffect(() => {
    if (authLoading || !user) {
      setDecks([])
      setLoadingDecks(false)
      return
    }

    setLoadingDecks(true)
    fetchDecks()
      .then(setDecks)
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoadingDecks(false))
  }, [authLoading, user])

  const loading = loadingWordSets || (Boolean(user) && loadingDecks)

  if (loading) {
    return <p className="text-muted">Loading…</p>
  }

  if (error) {
    return (
      <div className={themeClasses.alertError}>Failed to load content: {error}</div>
    )
  }

  return (
    <div className="space-y-10">
      <section>
        <h1 className={`mb-6 ${themeClasses.headingXl}`}>Word Sets</h1>
        <WordSetList wordSets={wordSets} />
      </section>

      {user ? (
        <section>
          <h2 className={`mb-6 ${themeClasses.headingXl}`}>Decks</h2>
          <DeckList decks={decks} />
        </section>
      ) : null}
    </div>
  )
}
