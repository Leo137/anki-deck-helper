import { screen, waitFor } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as wordSetsApi from '../api/wordSets'
import { renderWithProviders } from '../test/test-utils'
import HomePage from './HomePage'

describe('HomePage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('shows loading then word sets', async () => {
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockResolvedValue([
      { id: 1, name: 'Core', words_count: 42, created_at: '', updated_at: '' },
    ])

    renderWithProviders(<HomePage />)

    expect(screen.getByText(/loading word sets/i)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Word Sets' })).toBeInTheDocument()
    })

    expect(screen.getByRole('link', { name: /core/i })).toBeInTheDocument()
  })

  it('shows an error message when loading fails', async () => {
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockRejectedValue(new Error('Network error'))

    renderWithProviders(<HomePage />)

    expect(await screen.findByText(/failed to load word sets: network error/i)).toBeInTheDocument()
  })
})
