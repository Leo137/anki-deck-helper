import { Link } from 'react-router-dom'
import { themeClasses } from '../styles/theme'
import type { DeckCardSummary } from '../types/deck'

type DeckCardTableProps = {
  cards: DeckCardSummary[]
  deckId: number
  page: number
}

export default function DeckCardTable({ cards, deckId, page }: DeckCardTableProps) {
  if (cards.length === 0) {
    return (
      <p className={`${themeClasses.cardDashed} px-6 py-12 text-center text-muted`}>
        This deck has no cards yet.
      </p>
    )
  }

  return (
    <div className={themeClasses.tableShell}>
      <table className={themeClasses.table}>
        <thead className={themeClasses.tableHead}>
          <tr>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wide text-muted">
              Front
            </th>
            <th className="px-4 py-3 text-right text-xs font-medium uppercase tracking-wide text-muted">
              #
            </th>
          </tr>
        </thead>
        <tbody className={themeClasses.tableBody}>
          {cards.map((card) => (
            <tr key={card.id} className={themeClasses.tableRowHover}>
              <td className="px-4 py-3">
                <Link
                  to={`/decks/${deckId}/cards/${card.id}`}
                  state={{ deckId, page }}
                  className={`font-medium ${themeClasses.link}`}
                >
                  {card.front_preview || `Card ${card.position}`}
                </Link>
              </td>
              <td className="px-4 py-3 text-right tabular-nums text-muted">{card.position}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
