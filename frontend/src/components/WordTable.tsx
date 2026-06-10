import { Link } from 'react-router-dom'
import { themeClasses } from '../styles/theme'
import type { Word } from '../types/word'

type WordTableProps = {
  words: Word[]
  wordSetId: number
  page: number
}

export default function WordTable({ words, wordSetId, page }: WordTableProps) {
  if (words.length === 0) {
    return (
      <p className={`${themeClasses.cardDashed} px-6 py-12 text-center text-muted`}>
        This word set has no words.
      </p>
    )
  }

  return (
    <div className={themeClasses.tableShell}>
      <table className={themeClasses.table}>
        <thead className={themeClasses.tableHead}>
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
        <tbody className={themeClasses.tableBody}>
          {words.map((word) => (
            <tr key={word.id} className={themeClasses.tableRowHover}>
              <td className="px-4 py-3">
                <Link
                  to={`/words/${word.id}`}
                  state={{ wordSetId, page }}
                  className={`font-medium ${themeClasses.link}`}
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
                      <span key={tag} className={themeClasses.tag}>
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
