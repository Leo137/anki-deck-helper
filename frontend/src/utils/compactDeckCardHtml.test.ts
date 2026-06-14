import { describe, expect, it } from 'vitest'
import { compactDeckCardHtml } from './compactDeckCardHtml'

describe('compactDeckCardHtml', () => {
  it('removes single br tags', () => {
    const html = '<div class="definition">* only</div><br><div class="definition">* just</div>'

    expect(compactDeckCardHtml(html)).toBe(
      '<div class="definition">* only</div><div class="definition">* just</div>',
    )
  })

  it('converts double br tags into a single br', () => {
    const html = '<div class="tags">uk-prt</div><br><br><div class="tags">uk-prt</div>'

    expect(compactDeckCardHtml(html)).toBe(
      '<div class="tags">uk-prt</div><br><div class="tags">uk-prt</div>',
    )
  })

  it('handles self-closing and spaced br tags', () => {
    const html = '<div>a</div><br /><br /><div>b</div><br /><div>c</div>'

    expect(compactDeckCardHtml(html)).toBe('<div>a</div><br><div>b</div><div>c</div>')
  })
})
