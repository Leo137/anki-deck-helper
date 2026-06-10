import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import DefinitionLanguagePicker from './DefinitionLanguagePicker'

describe('DefinitionLanguagePicker', () => {
  it('renders nothing when only one language is available', () => {
    const { container } = render(
      <DefinitionLanguagePicker languages={['en']} value="en" onChange={vi.fn()} />,
    )

    expect(container).toBeEmptyDOMElement()
  })

  it('lists available languages and calls onChange when the selection changes', async () => {
    const user = userEvent.setup()
    const onChange = vi.fn()

    render(
      <DefinitionLanguagePicker
        languages={['en', 'fr']}
        value="en"
        onChange={onChange}
      />,
    )

    expect(screen.getByLabelText(/definitions/i)).toBeInTheDocument()
    expect(screen.getByRole('option', { name: 'English' })).toBeInTheDocument()
    expect(screen.getByRole('option', { name: 'French' })).toBeInTheDocument()

    await user.selectOptions(screen.getByLabelText(/definitions/i), 'fr')

    expect(onChange).toHaveBeenCalledWith('fr')
  })

  it('disables the select while definitions are loading', () => {
    render(
      <DefinitionLanguagePicker
        languages={['en', 'fr']}
        value="en"
        onChange={vi.fn()}
        disabled
      />,
    )

    expect(screen.getByLabelText(/definitions/i)).toBeDisabled()
  })
})
