import { screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { renderWithProviders } from '../test/test-utils'
import WordTable from './WordTable'

const sampleWord = {
  id: 7,
  content: '食べる',
  kana: 'たべる',
  reading: 'たべる',
  word_count: 4,
  tags: ['verb'],
  frequencies: [],
}

describe('WordTable', () => {
  it('shows an empty state when there are no words', () => {
    renderWithProviders(<WordTable words={[]} wordSetId={1} page={1} />)

    expect(screen.getByText(/this word set has no words/i)).toBeInTheDocument()
  })

  it('renders word rows with links back to the word set context', () => {
    renderWithProviders(<WordTable words={[sampleWord]} wordSetId={3} page={2} />)

    const link = screen.getByRole('link', { name: '食べる' })
    expect(link).toHaveAttribute('href', '/words/7')
    expect(screen.getByText('たべる')).toBeInTheDocument()
    expect(screen.getByText('verb')).toBeInTheDocument()
    expect(screen.getByText('4')).toBeInTheDocument()
  })
})
