import { screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'
import * as authApi from '../api/auth'
import { renderWithProviders } from '../test/test-utils'
import Layout from './Layout'

describe('Layout', () => {
  it('renders the app header and page content', async () => {
    vi.spyOn(authApi, 'fetchCurrentUser').mockRejectedValue(new Error('Unauthorized'))
    renderWithProviders(
      <Layout>
        <p>Page content</p>
      </Layout>,
    )

    expect(screen.getByRole('link', { name: 'Word Tracker' })).toHaveAttribute('href', '/')
    expect(screen.getByRole('combobox', { name: /search words and word sets/i })).toBeInTheDocument()
    expect(await screen.findByRole('button', { name: 'Log in' })).toBeInTheDocument()
    expect(screen.getByText('Page content')).toBeInTheDocument()
  })
})
