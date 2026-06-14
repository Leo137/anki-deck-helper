import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { fetchFrequencyTables } from '../api/decks'
import { fetchWordSets } from '../api/wordSets'
import CreateDeckForm from '../components/CreateDeckForm'
import GuestAuthPrompt from '../components/GuestAuthPrompt'
import { useAuth } from '../contexts/AuthContext'
import { themeClasses } from '../styles/theme'
import type { FrequencyTableSummary } from '../types/deck'
import type { WordSetSummary } from '../types/word'

export default function CreateDeckPage() {
  const navigate = useNavigate()
  const { user, loading: authLoading } = useAuth()
  const [wordSets, setWordSets] = useState<WordSetSummary[]>([])
  const [frequencyTables, setFrequencyTables] = useState<FrequencyTableSummary[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!user) {
      setWordSets([])
      setFrequencyTables([])
      return
    }

    setLoading(true)

    Promise.all([fetchWordSets(), fetchFrequencyTables()])
      .then(([nextWordSets, nextFrequencyTables]) => {
        setWordSets(nextWordSets)
        setFrequencyTables(nextFrequencyTables)
      })
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false))
  }, [user])

  if (authLoading) {
    return <p className="text-muted">Loading…</p>
  }

  if (!user) {
    return (
      <div>
        <h1 className={`mb-6 ${themeClasses.headingXl}`}>Create deck</h1>
        <GuestAuthPrompt
          title="Sign in to create decks"
          message="Deck creation is available for signed-in users. Log in or sign up to build your spaced repetition decks."
        />
      </div>
    )
  }

  if (loading) {
    return <p className="text-muted">Loading…</p>
  }

  if (error) {
    return (
      <div className={themeClasses.alertError}>Failed to load deck options: {error}</div>
    )
  }

  return (
    <div className="space-y-4">
      <Link to="/decks" className={themeClasses.linkSm}>
        ← Back to decks
      </Link>
      <CreateDeckForm
        wordSets={wordSets}
        frequencyTables={frequencyTables}
        onCreated={() => navigate('/decks')}
      />
    </div>
  )
}
