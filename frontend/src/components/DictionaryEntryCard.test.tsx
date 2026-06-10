import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import DictionaryEntryCard from './DictionaryEntryCard'

describe('DictionaryEntryCard', () => {
  it('renders dictionary text, readings, and definitions', () => {
    render(
      <DictionaryEntryCard
        entry={{
          text: '食べる',
          readings: ['たべる'],
          senses: [{ tags: ['v5r'], definitions: ['to eat'] }],
        }}
        fallbackWord="fallback"
      />,
    )

    expect(screen.getByRole('heading', { name: '食べる' })).toBeInTheDocument()
    expect(screen.getByText('たべる')).toBeInTheDocument()
    expect(screen.getByText('v5r')).toBeInTheDocument()
    expect(screen.getByText('to eat')).toBeInTheDocument()
  })

  it('uses the fallback word when entry text is empty', () => {
    render(
      <DictionaryEntryCard
        entry={{ text: '', readings: [], senses: [] }}
        fallbackWord="見る"
      />,
    )

    expect(screen.getByRole('heading', { name: '見る' })).toBeInTheDocument()
    expect(screen.getByText(/no definitions available/i)).toBeInTheDocument()
  })
})
