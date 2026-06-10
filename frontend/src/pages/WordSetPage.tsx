import { useEffect, useState } from 'react'
import { Link, useParams, useSearchParams } from 'react-router-dom'
import { fetchWordSet, fetchWordSetWords } from '../api/wordSets'
import PaginationControls from '../components/PaginationControls'
import WordTable from '../components/WordTable'
import { themeClasses } from '../styles/theme'
import type { Pagination, Word, WordSetDetail } from '../types/word'

export default function WordSetPage() {
  const { id } = useParams<{ id: string }>()
  const [searchParams, setSearchParams] = useSearchParams()
  const page = Math.max(Number(searchParams.get('page') ?? '1'), 1)

  const [wordSet, setWordSet] = useState<WordSetDetail | null>(null)
  const [words, setWords] = useState<Word[]>([])
  const [pagination, setPagination] = useState<Pagination | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!id) return

    setLoading(true)
    setError(null)

    Promise.all([fetchWordSet(Number(id)), fetchWordSetWords(Number(id), page)])
      .then(([wordSetData, wordsData]) => {
        setWordSet(wordSetData)
        setWords(wordsData.words)
        setPagination(wordsData.pagination)
      })
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false))
  }, [id, page])

  const handlePageChange = (nextPage: number) => {
    setSearchParams(nextPage > 1 ? { page: String(nextPage) } : {})
  }

  if (loading) {
    return <p className="text-muted">Loading word set…</p>
  }

  if (error || !wordSet) {
    return (
      <div>
        <Link to="/" className={themeClasses.linkSm}>
          ← Back to word sets
        </Link>
        <div className={`mt-4 ${themeClasses.alertError}`}>{error ?? 'Word set not found'}</div>
      </div>
    )
  }

  return (
    <div>
      <Link to="/" className={themeClasses.linkSm}>
        ← Back to word sets
      </Link>
      <div className="mt-4 mb-6">
        <h1 className={themeClasses.headingXl}>{wordSet.name}</h1>
        <p className="mt-1 text-muted">
          {wordSet.words_count.toLocaleString()} {wordSet.words_count === 1 ? 'word' : 'words'}
        </p>
      </div>
      <WordTable words={words} wordSetId={wordSet.id} page={page} />
      {pagination && (
        <PaginationControls pagination={pagination} onPageChange={handlePageChange} />
      )}
    </div>
  )
}
