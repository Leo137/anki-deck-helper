import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it } from 'vitest'
import { renderWithProviders } from '../test/test-utils'
import ThemeToggle from './ThemeToggle'

describe('ThemeToggle', () => {
  it('cycles theme preference when clicked', async () => {
    const user = userEvent.setup()

    renderWithProviders(<ThemeToggle />)

    const button = screen.getByRole('button')
    expect(button).toHaveAccessibleName(/theme: system/i)

    await user.click(button)
    expect(button).toHaveAccessibleName(/theme: light/i)

    await user.click(button)
    expect(button).toHaveAccessibleName(/theme: dark/i)
  })
})
