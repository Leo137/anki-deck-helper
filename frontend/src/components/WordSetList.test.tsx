import { screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { renderWithProviders } from '../test/test-utils'
import WordSetList from './WordSetList'

describe('WordSetList', () => {
  it('shows an empty state when there are no word sets', () => {
    renderWithProviders(<WordSetList wordSets={[]} />)

    expect(screen.getByText(/no word sets yet/i)).toBeInTheDocument()
  })

  it('renders word set links with counts', () => {
    renderWithProviders(
      <WordSetList
        wordSets={[
          { id: 1, name: 'Core', words_count: 120, created_at: '', updated_at: '' },
          { id: 2, name: 'JLPT N5', words_count: 1, created_at: '', updated_at: '' },
        ]}
      />,
    )

    expect(screen.getByRole('link', { name: /core/i })).toHaveAttribute('href', '/word-sets/1')
    expect(screen.getByText('120 words')).toBeInTheDocument()
    expect(screen.getByText('1 word')).toBeInTheDocument()
  })
})
