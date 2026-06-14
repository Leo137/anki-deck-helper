import { screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { renderWithProviders } from '../test/test-utils'
import MainNav from './MainNav'

describe('MainNav', () => {
  it('renders links to word sets and decks', () => {
    renderWithProviders(<MainNav />, { route: '/word-sets' })

    expect(screen.getByRole('link', { name: 'Word Sets' })).toHaveAttribute('href', '/word-sets')
    expect(screen.getByRole('link', { name: 'Decks' })).toHaveAttribute('href', '/decks')
  })
})
