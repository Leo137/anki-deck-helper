const DOUBLE_BR_PLACEHOLDER = '\u0000DECK_CARD_DOUBLE_BR\u0000'
const BR_TAG_PATTERN = /<br\s*\/?>/gi
const DOUBLE_BR_PATTERN = /(?:<br\s*\/?>\s*){2}/gi

export function compactDeckCardHtml(html: string): string {
  const withPreservedDoubleBreaks = html.replace(DOUBLE_BR_PATTERN, DOUBLE_BR_PLACEHOLDER)
  const withoutSingleBreaks = withPreservedDoubleBreaks.replace(BR_TAG_PATTERN, '')

  return withoutSingleBreaks.replaceAll(DOUBLE_BR_PLACEHOLDER, '<br>')
}
