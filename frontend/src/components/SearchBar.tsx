import { useEffect, useId, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { search } from '../api/search'
import { useDebouncedValue } from '../hooks/useDebouncedValue'
import { themeClasses } from '../styles/theme'
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
        className={themeClasses.input}
      />

      {showDropdown && (
        <div id={listboxId} role="listbox" className={themeClasses.dropdownPanel}>
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
                      className={themeClasses.dropdownItem}
                    >
                      <span className={`font-medium ${themeClasses.heading}`}>{wordSet.name}</span>
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
                      className={themeClasses.dropdownItemWithGap}
                    >
                      <span className={`font-medium ${themeClasses.heading}`}>{word.content}</span>
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
