import { describe, expect, it } from 'vitest'
import { languageLabel } from './languageLabels'

describe('languageLabel', () => {
  it('returns a friendly label for known language codes', () => {
    expect(languageLabel('en')).toBe('English')
    expect(languageLabel('fr')).toBe('French')
    expect(languageLabel('ja')).toBe('Japanese')
  })

  it('falls back to an uppercased code for unknown languages', () => {
    expect(languageLabel('zh')).toBe('ZH')
  })
})
