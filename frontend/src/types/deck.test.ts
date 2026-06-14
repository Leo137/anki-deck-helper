import { describe, expect, it } from 'vitest'
import type { DeckCard, DeckCardField } from './deck'

describe('deck types', () => {
  it('describes a deck card with front and back HTML fields', () => {
    const front: DeckCardField = {
      id: 1,
      side: 'front',
      html_content: '<h1>ふもと</h1>',
      created_at: '',
      updated_at: '',
    }
    const back: DeckCardField = {
      id: 2,
      side: 'back',
      html_content:
        '<div class="reading">ふもと</div><br><hr><div class="tags">uk-n</div><br>' +
        '<div class="definition">* foot (of a mountain or hill)</div><br>',
      created_at: '',
      updated_at: '',
    }
    const card: DeckCard = {
      id: 10,
      position: 1,
      fields: [front, back],
      created_at: '',
      updated_at: '',
    }

    expect(card.fields).toHaveLength(2)
    expect(card.fields.map((field) => field.side)).toEqual(['front', 'back'])
    expect(card.fields[0].html_content).toContain('<h1>ふもと</h1>')
    expect(card.fields[1].html_content).toContain('class="definition"')
  })
})
