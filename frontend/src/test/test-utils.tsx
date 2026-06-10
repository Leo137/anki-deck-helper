import { render, type RenderOptions } from '@testing-library/react'
import { MemoryRouter, type MemoryRouterProps } from 'react-router-dom'
import { AuthProvider } from '../contexts/AuthContext'
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
      <AuthProvider>
        <MemoryRouter initialEntries={[route]} {...routerProps}>
          {ui}
        </MemoryRouter>
      </AuthProvider>
    </ThemeProvider>,
    options,
  )
}
