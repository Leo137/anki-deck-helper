import { render, type RenderOptions } from '@testing-library/react'
import { MemoryRouter, type MemoryRouterProps } from 'react-router-dom'
import { ThemeProvider } from '../contexts/ThemeContext'

type ProviderOptions = {
  route?: string
  routerProps?: Omit<MemoryRouterProps, 'children'>
}

export function renderWithProviders(
  ui: React.ReactElement,
  { route = '/', routerProps }: ProviderOptions = {},
  options?: Omit<RenderOptions, 'wrapper'>,
) {
  return render(
    <ThemeProvider>
      <MemoryRouter initialEntries={[route]} {...routerProps}>
        {ui}
      </MemoryRouter>
    </ThemeProvider>,
    options,
  )
}
