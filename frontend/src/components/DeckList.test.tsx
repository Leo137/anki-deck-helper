import { screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { renderWithProviders } from '../test/test-utils'
import DeckList from './DeckList'

describe('DeckList', () => {
  it('shows an empty state when there are no decks', () => {
    renderWithProviders(<DeckList decks={[]} />)

    expect(screen.getByText(/no decks yet/i)).toBeInTheDocument()
  })

  it('renders deck cards with counts', () => {
    renderWithProviders(
      <DeckList
        decks={[
          { id: 1, name: 'SRS Core', words_count: 120, created_at: '', updated_at: '' },
          { id: 2, name: 'Daily Review', words_count: 1, created_at: '', updated_at: '' },
        ]}
      />,
    )

    expect(screen.getByText('SRS Core')).toBeInTheDocument()
    expect(screen.getByText('120 words')).toBeInTheDocument()
    expect(screen.getByText('1 word')).toBeInTheDocument()
  })
})
