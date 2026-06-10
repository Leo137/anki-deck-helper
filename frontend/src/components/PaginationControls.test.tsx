import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { renderWithProviders } from '../test/test-utils'
import PaginationControls from './PaginationControls'

describe('PaginationControls', () => {
  it('renders nothing when there is only one page', () => {
    const { container } = renderWithProviders(
      <PaginationControls
        pagination={{ page: 1, per_page: 50, total_count: 10, total_pages: 1 }}
        onPageChange={vi.fn()}
      />,
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('shows range text and calls onPageChange', async () => {
    const user = userEvent.setup()
    const onPageChange = vi.fn()

    renderWithProviders(
      <PaginationControls
        pagination={{ page: 2, per_page: 50, total_count: 120, total_pages: 3 }}
        onPageChange={onPageChange}
      />,
    )

    expect(screen.getByText(/showing 51–100 of 120 words/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '2' })).toHaveAttribute('aria-current', 'page')

    await user.click(screen.getByRole('button', { name: 'Next' }))
    expect(onPageChange).toHaveBeenCalledWith(3)
  })
})
