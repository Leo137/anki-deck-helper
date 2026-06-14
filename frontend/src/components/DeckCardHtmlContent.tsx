import { compactDeckCardHtml } from '../utils/compactDeckCardHtml'

type DeckCardHtmlContentProps = {
  html: string
}

export default function DeckCardHtmlContent({ html }: DeckCardHtmlContentProps) {
  return (
    <div
      className="deck-card-html"
      dangerouslySetInnerHTML={{ __html: compactDeckCardHtml(html) }}
    />
  )
}
