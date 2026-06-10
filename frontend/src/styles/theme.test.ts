import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { describe, expect, it } from 'vitest'
import { themeClasses, themeColorTokens } from './theme'

const HARDCODED_COLOR_PATTERN =
  /\b(?:bg|text|border|divide|ring|from|to|via|fill|stroke)-(?:gray|red|white|black|slate|zinc|neutral|stone|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-\d+/i

describe('themeClasses', () => {
  it('exports composite classes for every UI pattern', () => {
    expect(Object.keys(themeClasses).length).toBeGreaterThanOrEqual(20)
    expect(themeClasses.alertError).toContain('error-bg')
    expect(themeClasses.card).toContain('border-border')
    expect(themeClasses.paginationPageActive).toContain('text-on-primary')
  })

  it('uses semantic tokens instead of hardcoded palette classes', () => {
    for (const [key, className] of Object.entries(themeClasses)) {
      expect(className, `${key} should not use hardcoded Tailwind palette classes`).not.toMatch(
        HARDCODED_COLOR_PATTERN,
      )
    }
  })
})

describe('themeColorTokens', () => {
  it('lists every semantic color token used by the app theme', () => {
    expect(themeColorTokens).toEqual(
      expect.arrayContaining([
        'primary',
        'foreground',
        'border',
        'error-bg',
        'error-border',
        'error-foreground',
      ]),
    )
  })

  it('defines each token in index.css for light and dark modes', () => {
    const cssPath = resolve(import.meta.dirname, '../index.css')
    const css = readFileSync(cssPath, 'utf8')

    for (const token of themeColorTokens) {
      expect(css, `missing --color-${token} in index.css`).toContain(`--color-${token}:`)
    }

    expect(css).toMatch(/@layer theme[\s\S]*\.dark[\s\S]*--color-foreground:/)
  })
})

describe('theme adoption in components', () => {
  const componentPaths = [
    '../components/SearchBar.tsx',
    '../components/WordTable.tsx',
    '../components/PaginationControls.tsx',
    '../components/DictionaryEntryCard.tsx',
    '../components/ThemeToggle.tsx',
    '../components/Layout.tsx',
    '../components/WordSetList.tsx',
    '../pages/HomePage.tsx',
    '../pages/WordSetPage.tsx',
    '../pages/WordDetailPage.tsx',
  ]

  it('imports themeClasses instead of hardcoded palette colors', () => {
    for (const relativePath of componentPaths) {
      const source = readFileSync(resolve(import.meta.dirname, relativePath), 'utf8')

      expect(source, `${relativePath} should import themeClasses`).toContain('themeClasses')
      expect(source, `${relativePath} should not use hardcoded palette classes`).not.toMatch(
        HARDCODED_COLOR_PATTERN,
      )
    }
  })
})
