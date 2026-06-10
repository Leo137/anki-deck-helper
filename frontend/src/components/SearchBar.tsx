import { useEffect, useId, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { search } from '../api/search'
import { useDebouncedValue } from '../hooks/useDebouncedValue'
import type { SearchResults } from '../types/search'

export default function SearchBar() {
  const inputId = useId()
  const listboxId = useId()
  const navigate = useNavigate()
  const containerRef = useRef<HTMLDivElement>(null)

  const [query, setQuery] = useState('')
  const [results, setResults] = useState<SearchResults | null>(null)
  const [loading, setLoading] = useState(false)
  const [open, setOpen] = useState(false)

  const debouncedQuery = useDebouncedValue(query, 300)

  useEffect(() => {
    if (!debouncedQuery.trim()) {
      setResults(null)
      setLoading(false)
      return
    }

    let cancelled = false
    setLoading(true)

    search(debouncedQuery.trim())
      .then((data) => {
        if (!cancelled) {
          setResults(data)
          setOpen(true)
        }
      })
      .catch(() => {
        if (!cancelled) {
          setResults({ query: debouncedQuery, words: [], word_sets: [] })
          setOpen(true)
        }
      })
      .finally(() => {
        if (!cancelled) {
          setLoading(false)
        }
      })

    return () => {
      cancelled = true
    }
  }, [debouncedQuery])

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setOpen(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  const hasResults =
    results && (results.words.length > 0 || results.word_sets.length > 0)
  const showDropdown = Boolean(open && query.trim().length > 0 && (loading || results))

  function handleSelectWord(wordId: number) {
    setOpen(false)
    setQuery('')
    navigate(`/words/${wordId}`)
  }

  function handleSelectWordSet(wordSetId: number) {
    setOpen(false)
    setQuery('')
    navigate(`/word-sets/${wordSetId}`)
  }

  return (
    <div ref={containerRef} className="relative ml-auto w-full max-w-md">
      <label htmlFor={inputId} className="sr-only">
        Search words and word sets
      </label>
      <input
        id={inputId}
        type="search"
        role="combobox"
        aria-expanded={showDropdown}
        aria-controls={listboxId}
        aria-autocomplete="list"
        placeholder="Search kanji, kana, or word set…"
        value={query}
        onChange={(event) => {
          setQuery(event.target.value)
          setOpen(true)
        }}
        onFocus={() => {
          if (query.trim()) {
            setOpen(true)
          }
        }}
        className="w-full rounded-lg border border-gray-300 bg-elevated px-3 py-2 text-sm text-gray-900 placeholder:text-muted focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20 dark:border-gray-600 dark:text-gray-100"
      />

      {showDropdown && (
        <div
          id={listboxId}
          role="listbox"
          className="absolute top-full z-50 mt-1 max-h-80 w-full overflow-y-auto rounded-lg border border-gray-200 bg-elevated py-2 shadow-lg dark:border-gray-700"
        >
          {loading && <p className="px-4 py-2 text-sm text-muted">Searching…</p>}

          {!loading && results && results.word_sets.length > 0 && (
            <div className="px-2 pb-1">
              <p className="px-2 py-1 text-xs font-medium uppercase tracking-wide text-muted">
                Word sets
              </p>
              <ul>
                {results.word_sets.map((wordSet) => (
                  <li key={wordSet.id}>
                    <button
                      type="button"
                      role="option"
                      onClick={() => handleSelectWordSet(wordSet.id)}
                      className="flex w-full items-center justify-between rounded-md px-3 py-2 text-left text-sm hover:bg-gray-50 dark:hover:bg-gray-800"
                    >
                      <span className="font-medium text-gray-900 dark:text-gray-100">{wordSet.name}</span>
                      <span className="text-xs text-muted">
                        {wordSet.words_count.toLocaleString()} words
                      </span>
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {!loading && results && results.words.length > 0 && (
            <div className="px-2 pb-1">
              <p className="px-2 py-1 text-xs font-medium uppercase tracking-wide text-muted">
                Words
              </p>
              <ul>
                {results.words.map((word) => (
                  <li key={word.id}>
                    <button
                      type="button"
                      role="option"
                      onClick={() => handleSelectWord(word.id)}
                      className="flex w-full items-center justify-between gap-3 rounded-md px-3 py-2 text-left text-sm hover:bg-gray-50 dark:hover:bg-gray-800"
                    >
                      <span className="font-medium text-gray-900 dark:text-gray-100">{word.content}</span>
                      <span className="truncate text-xs text-muted">{word.reading ?? '—'}</span>
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {!loading && results && !hasResults && (
            <p className="px-4 py-2 text-sm text-muted">No matches found.</p>
          )}
        </div>
      )}
    </div>
  )
}
