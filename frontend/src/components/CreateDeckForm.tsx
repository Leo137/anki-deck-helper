import { useState, type FormEvent } from 'react'
import { createDeck } from '../api/decks'
import { themeClasses } from '../styles/theme'
import type { DeckSummary, FrequencyTableSummary } from '../types/deck'
import type { WordSetSummary } from '../types/word'

type CreateDeckFormProps = {
  wordSets: WordSetSummary[]
  frequencyTables: FrequencyTableSummary[]
  onCreated: (deck: DeckSummary) => void
}

export default function CreateDeckForm({ wordSets, frequencyTables, onCreated }: CreateDeckFormProps) {
  const [name, setName] = useState('')
  const [selectedWordSetIds, setSelectedWordSetIds] = useState<number[]>([])
  const [selectedFrequencyTableIds, setSelectedFrequencyTableIds] = useState<number[]>([])
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  function toggleId(current: number[], id: number) {
    return current.includes(id) ? current.filter((value) => value !== id) : [...current, id]
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setSubmitting(true)
    setError(null)

    try {
      const deck = await createDeck({
        name: name.trim(),
        word_set_ids: selectedWordSetIds,
        frequency_table_ids: selectedFrequencyTableIds,
      })
      setName('')
      setSelectedWordSetIds([])
      setSelectedFrequencyTableIds([])
      onCreated(deck)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create deck')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className={`${themeClasses.cardPadded} space-y-5`}>
      <div>
        <h3 className={themeClasses.headingLg}>Create deck</h3>
        <p className="mt-1 text-sm text-muted">
          Choose word sets and frequency tables. Cards are generated in the background.
        </p>
      </div>

      <label className="block text-sm font-medium text-foreground" htmlFor="deck-name">
        Deck name
        <input
          id="deck-name"
          className={`${themeClasses.input} mt-1`}
          value={name}
          onChange={(event) => setName(event.target.value)}
          placeholder="Daily review"
          required
        />
      </label>

      <fieldset>
        <legend className="text-sm font-medium text-foreground">Word sets</legend>
        <div className="mt-2 space-y-2">
          {wordSets.map((wordSet) => (
            <label key={wordSet.id} className="flex items-center gap-2 text-sm text-secondary">
              <input
                type="checkbox"
                checked={selectedWordSetIds.includes(wordSet.id)}
                onChange={() => setSelectedWordSetIds((current) => toggleId(current, wordSet.id))}
              />
              <span>
                {wordSet.name} ({wordSet.words_count.toLocaleString()} words)
              </span>
            </label>
          ))}
        </div>
      </fieldset>

      <fieldset>
        <legend className="text-sm font-medium text-foreground">Frequency tables</legend>
        <div className="mt-2 space-y-2">
          {frequencyTables.map((frequencyTable) => (
            <label key={frequencyTable.id} className="flex items-center gap-2 text-sm text-secondary">
              <input
                type="checkbox"
                checked={selectedFrequencyTableIds.includes(frequencyTable.id)}
                onChange={() =>
                  setSelectedFrequencyTableIds((current) => toggleId(current, frequencyTable.id))
                }
              />
              <span>{frequencyTable.name}</span>
            </label>
          ))}
        </div>
      </fieldset>

      {error ? <div className={themeClasses.alertError}>{error}</div> : null}

      <button
        type="submit"
        className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-on-primary hover:bg-primary-hover disabled:cursor-not-allowed disabled:opacity-60"
        disabled={
          submitting ||
          !name.trim() ||
          selectedWordSetIds.length === 0 ||
          selectedFrequencyTableIds.length === 0
        }
      >
        {submitting ? 'Creating…' : 'Create deck'}
      </button>
    </form>
  )
}
