import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { renderWithProviders } from '../test/test-utils'
import DeleteDeckModal from './DeleteDeckModal'

const readyDeck = {
  id: 1,
  name: 'SRS Core',
  status: 'ready' as const,
  error_message: null,
  cards_count: 10,
  generation_progress: 100,
  generation_total: null,
  created_at: '',
  updated_at: '',
}

const pendingDeck = {
  ...readyDeck,
  id: 2,
  name: 'Building',
  status: 'pending' as const,
  generation_progress: 0,
  cards_count: 0,
}

describe('DeleteDeckModal', () => {
  it('asks to delete a ready deck', () => {
    renderWithProviders(
      <DeleteDeckModal deck={readyDeck} confirming={false} onCancel={() => undefined} onConfirm={() => undefined} />,
    )

    expect(screen.getByRole('dialog', { name: /delete deck/i })).toBeInTheDocument()
    expect(screen.getByText(/permanently delete "SRS Core"/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /delete deck/i })).toBeInTheDocument()
  })

  it('asks to cancel generation for queued decks', () => {
    renderWithProviders(
      <DeleteDeckModal deck={pendingDeck} confirming={false} onCancel={() => undefined} onConfirm={() => undefined} />,
    )

    expect(screen.getByRole('dialog', { name: /cancel deck generation/i })).toBeInTheDocument()
    expect(screen.getByText(/stop generating "Building"/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /cancel and delete/i })).toBeInTheDocument()
  })

  it('calls the confirm and cancel handlers', async () => {
    const user = userEvent.setup()
    const onCancel = vi.fn()
    const onConfirm = vi.fn()

    renderWithProviders(
      <DeleteDeckModal deck={readyDeck} confirming={false} onCancel={onCancel} onConfirm={onConfirm} />,
    )

    await user.click(screen.getByRole('button', { name: /^cancel$/i }))
    await user.click(screen.getByRole('button', { name: /delete deck/i }))

    expect(onCancel).toHaveBeenCalledTimes(1)
    expect(onConfirm).toHaveBeenCalledTimes(1)
  })
})
