import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import * as decksApi from '../api/decks'
import { renderWithProviders } from '../test/test-utils'
import CreateDeckForm from './CreateDeckForm'

describe('CreateDeckForm', () => {
  it('submits selected word sets and frequency tables', async () => {
    const user = userEvent.setup()
    const onCreated = vi.fn()
    const createDeck = vi.spyOn(decksApi, 'createDeck').mockResolvedValue({
      id: 1,
      name: 'Daily Review',
      status: 'pending',
      error_message: null,
      generation_progress: 0,
      generation_total: null,
      cards_count: 0,
      created_at: '',
      updated_at: '',
    })

    renderWithProviders(
      <CreateDeckForm
        wordSets={[{ id: 10, name: 'Core', words_count: 5, created_at: '', updated_at: '' }]}
        frequencyTables={[{ id: 20, name: 'jpdb', created_at: '', updated_at: '' }]}
        onCreated={onCreated}
      />,
    )

    await user.type(screen.getByLabelText(/deck name/i), 'Daily Review')
    await user.click(screen.getByRole('checkbox', { name: /core/i }))
    await user.click(screen.getByRole('checkbox', { name: /jpdb/i }))
    await user.click(screen.getByRole('button', { name: /create deck/i }))

    await waitFor(() => {
      expect(createDeck).toHaveBeenCalledWith({
        name: 'Daily Review',
        word_set_ids: [10],
        frequency_table_ids: [20],
      })
    })
    expect(onCreated).toHaveBeenCalled()
  })
})
