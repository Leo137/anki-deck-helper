import { Link } from 'react-router-dom'
import type { Word } from '../types/word'

type WordTableProps = {
  words: Word[]
  wordSetId: number
  page: number
}

export default function WordTable({ words, wordSetId, page }: WordTableProps) {
  if (words.length === 0) {
    return (
      <p className="rounded-lg border border-dashed border-gray-300 bg-elevated px-6 py-12 text-center text-muted dark:border-gray-600">
        This word set has no words.
      </p>
    )
  }

  return (
    <div className="overflow-hidden rounded-lg border border-gray-200 bg-elevated shadow-sm dark:border-gray-700">
      <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
        <thead className="bg-gray-50 dark:bg-gray-800/50">
          <tr>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wide text-muted">
              Word
            </th>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wide text-muted">
              Reading
            </th>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wide text-muted">
              Tags
            </th>
            <th className="px-4 py-3 text-right text-xs font-medium uppercase tracking-wide text-muted">
              Count
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
          {words.map((word) => (
            <tr key={word.id} className="hover:bg-gray-50 dark:hover:bg-gray-800/50">
              <td className="px-4 py-3">
                <Link
                  to={`/words/${word.id}`}
                  state={{ wordSetId, page }}
                  className="font-medium text-primary hover:underline"
                >
                  {word.content}
                </Link>
              </td>
              <td className="px-4 py-3 text-muted">{word.reading ?? '—'}</td>
              <td className="px-4 py-3">
                <div className="flex flex-wrap gap-1">
                  {word.tags.length === 0 ? (
                    <span className="text-muted">—</span>
                  ) : (
                    word.tags.map((tag) => (
                      <span
                        key={tag}
                        className="rounded-full bg-gray-100 px-2 py-0.5 font-mono text-xs text-gray-700 dark:bg-gray-800 dark:text-gray-300"
                      >
                        {tag}
                      </span>
                    ))
                  )}
                </div>
              </td>
              <td className="px-4 py-3 text-right tabular-nums text-muted">{word.word_count}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
