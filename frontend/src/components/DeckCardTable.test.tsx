import { screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { renderWithProviders } from '../test/test-utils'
import DeckCardTable from './DeckCardTable'

describe('DeckCardTable', () => {
  it('shows an empty state when there are no cards', () => {
    renderWithProviders(<DeckCardTable cards={[]} deckId={1} page={1} />)

    expect(screen.getByText(/this deck has no cards yet/i)).toBeInTheDocument()
  })

  it('renders card rows with links to card detail', () => {
    renderWithProviders(
      <DeckCardTable
        deckId={5}
        page={2}
        cards={[
          {
            id: 10,
            position: 1,
            front_preview: '半導体',
            created_at: '',
            updated_at: '',
          },
        ]}
      />,
      { route: '/decks/5' },
    )

    const link = screen.getByRole('link', { name: '半導体' })
    expect(link).toHaveAttribute('href', '/decks/5/cards/10')
  })
})
