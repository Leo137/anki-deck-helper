import { useCallback, useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { deleteDeck, fetchDecks } from '../api/decks'
import DeleteDeckModal from '../components/DeleteDeckModal'
import DeckList from '../components/DeckList'
import GuestAuthPrompt from '../components/GuestAuthPrompt'
import { useAuth } from '../contexts/AuthContext'
import { themeClasses } from '../styles/theme'
import type { DeckSummary } from '../types/deck'

const ACTIVE_DECK_STATUSES = new Set<DeckSummary['status']>(['pending', 'processing'])

export default function DecksPage() {
  const { user, loading: authLoading } = useAuth()
  const [decks, setDecks] = useState<DeckSummary[]>([])
  const [loadingDecks, setLoadingDecks] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [actionError, setActionError] = useState<string | null>(null)
  const [deletingId, setDeletingId] = useState<number | null>(null)
  const [deckToDelete, setDeckToDelete] = useState<DeckSummary | null>(null)

  const loadDecks = useCallback((options: { showLoading?: boolean } = {}) => {
    const { showLoading = true } = options
    if (!user) {
      setDecks([])
      return Promise.resolve()
    }

    if (showLoading) {
      setLoadingDecks(true)
    }
    return fetchDecks()
      .then(setDecks)
      .catch((err: Error) => setError(err.message))
      .finally(() => {
        if (showLoading) {
          setLoadingDecks(false)
        }
      })
  }, [user])

  const handleRequestDelete = useCallback((deck: DeckSummary) => {
    setActionError(null)
    setDeckToDelete(deck)
  }, [])

  const handleConfirmDelete = useCallback(async () => {
    if (!deckToDelete) {
      return
    }

    const deck = deckToDelete
    setDeletingId(deck.id)
    setActionError(null)

    try {
      await deleteDeck(deck.id)
      setDecks((current) => current.filter((item) => item.id !== deck.id))
      setDeckToDelete(null)
    } catch (err) {
      setActionError(err instanceof Error ? err.message : 'Failed to delete deck')
    } finally {
      setDeletingId(null)
    }
  }, [deckToDelete])

  useEffect(() => {
    if (authLoading) return
    void loadDecks()
  }, [authLoading, loadDecks])

  useEffect(() => {
    if (!user || !decks.some((deck) => ACTIVE_DECK_STATUSES.has(deck.status))) {
      return
    }

    const intervalId = window.setInterval(() => {
      void loadDecks({ showLoading: false })
    }, 3000)

    return () => window.clearInterval(intervalId)
  }, [decks, loadDecks, user])

  if (authLoading) {
    return <p className="text-muted">Loading…</p>
  }

  if (!user) {
    return (
      <div>
        <h1 className={`mb-6 ${themeClasses.headingXl}`}>Decks</h1>
        <GuestAuthPrompt
          title="Sign in to use decks"
          message="Decks are available for signed-in users. Log in or sign up to create and manage your spaced repetition decks."
        />
      </div>
    )
  }

  if (loadingDecks) {
    return <p className="text-muted">Loading decks…</p>
  }

  if (error) {
    return (
      <div className={themeClasses.alertError}>Failed to load decks: {error}</div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-4">
        <h1 className={themeClasses.headingXl}>Decks</h1>
        <Link
          to="/decks/new"
          className="shrink-0 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-on-primary hover:bg-primary-hover"
        >
          Create deck
        </Link>
      </div>
      {actionError ? (
        <div className={themeClasses.alertError}>{actionError}</div>
      ) : null}
      <DeckList decks={decks} deletingId={deletingId} onDelete={handleRequestDelete} />
      {deckToDelete ? (
        <DeleteDeckModal
          deck={deckToDelete}
          confirming={deletingId === deckToDelete.id}
          onCancel={() => {
            if (deletingId !== deckToDelete.id) {
              setDeckToDelete(null)
            }
          }}
          onConfirm={() => void handleConfirmDelete()}
        />
      ) : null}
    </div>
  )
}
