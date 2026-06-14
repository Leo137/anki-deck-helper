import { screen, waitFor } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as authApi from '../api/auth'
import * as wordSetsApi from '../api/wordSets'
import { setAuthToken } from '../api/client'
import { themeClasses } from '../styles/theme'
import { renderWithProviders } from '../test/test-utils'
import WordSetsPage from './WordSetsPage'

describe('WordSetsPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    setAuthToken(null)
  })

  it('shows loading then word sets', async () => {
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockResolvedValue([
      { id: 1, name: 'Core', words_count: 42, created_at: '', updated_at: '' },
    ])

    renderWithProviders(<WordSetsPage />)

    expect(screen.getByText(/loading word sets/i)).toBeInTheDocument()

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Word Sets' })).toBeInTheDocument()
    })

    expect(screen.getByRole('link', { name: /core/i })).toBeInTheDocument()
  })

  it('shows an error message when loading fails', async () => {
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockRejectedValue(new Error('Network error'))

    renderWithProviders(<WordSetsPage />)

    const alert = await screen.findByText(/failed to load word sets: network error/i)
    expect(alert).toBeInTheDocument()
    expect(alert).toHaveClass('bg-error-bg')
  })

  it('applies theme heading classes to the page title', async () => {
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))
    vi.spyOn(wordSetsApi, 'fetchWordSets').mockResolvedValue([])

    renderWithProviders(<WordSetsPage />)

    const heading = await screen.findByRole('heading', { name: 'Word Sets' })
    expect(heading.className).toContain(themeClasses.headingXl)
  })
})
