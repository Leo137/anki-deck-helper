import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { renderWithProviders } from '../test/test-utils'
import DeckList from './DeckList'

const baseDeck = {
  error_message: null,
  cards_count: 0,
  generation_total: null,
  created_at: '',
  updated_at: '',
}

const noop = () => {}

describe('DeckList', () => {
  it('shows an empty state when there are no decks', () => {
    renderWithProviders(<DeckList decks={[]} onDelete={noop} />)

    expect(screen.getByText(/no decks yet/i)).toBeInTheDocument()
  })

  it('renders deck cards with counts and status', () => {
    renderWithProviders(
      <DeckList
        decks={[
          {
            ...baseDeck,
            id: 1,
            name: 'SRS Core',
            status: 'ready',
            generation_progress: 100,
            cards_count: 120,
          },
          {
            ...baseDeck,
            id: 2,
            name: 'Daily Review',
            status: 'processing',
            generation_progress: 45,
            generation_total: 100,
            cards_count: 45,
          },
        ]}
        onDelete={noop}
      />,
    )

    expect(screen.getByText('SRS Core')).toBeInTheDocument()
    expect(screen.getByText('120 cards')).toBeInTheDocument()
    expect(screen.getByText('Ready')).toBeInTheDocument()
    expect(screen.getByText('Generating')).toBeInTheDocument()
    expect(screen.getByText('45%')).toBeInTheDocument()
    expect(screen.getByText('45 / 100 cards')).toBeInTheDocument()
    expect(screen.getByRole('progressbar', { name: /daily review generation progress/i })).toHaveAttribute(
      'aria-valuenow',
      '45',
    )
  })

  it('shows deck errors when generation fails', () => {
    renderWithProviders(
      <DeckList
        decks={[
          {
            ...baseDeck,
            id: 3,
            name: 'Broken',
            status: 'failed',
            generation_progress: 12,
            generation_total: 200,
            error_message: 'No words found for the selected word sets',
          },
        ]}
        onDelete={noop}
      />,
    )

    expect(screen.getByText('Failed')).toBeInTheDocument()
    expect(screen.getByText(/no words found/i)).toBeInTheDocument()
    expect(screen.getByText('0 cards')).toBeInTheDocument()
  })

  it('calls onDelete when the delete icon is clicked', async () => {
    const user = userEvent.setup()
    const onDelete = vi.fn()
    const deck = {
      ...baseDeck,
      id: 4,
      name: 'Review',
      status: 'ready' as const,
      generation_progress: 100,
      cards_count: 10,
    }

    renderWithProviders(<DeckList decks={[deck]} onDelete={onDelete} />)

    await user.click(screen.getByRole('button', { name: /delete deck review/i }))

    expect(onDelete).toHaveBeenCalledWith(deck)
  })

  it('shows cancel for generating decks', () => {
    renderWithProviders(
      <DeckList
        decks={[
          {
            ...baseDeck,
            id: 5,
            name: 'Building',
            status: 'pending',
            generation_progress: 0,
          },
        ]}
        onDelete={noop}
      />,
    )

    expect(screen.getByRole('button', { name: /cancel deck building/i })).toBeInTheDocument()
  })
})
