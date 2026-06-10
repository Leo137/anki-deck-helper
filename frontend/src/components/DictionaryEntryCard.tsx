import { themeClasses } from '../styles/theme'

export type DictionarySense = {
  tags: string[]
  definitions: string[]
}

export type DictionaryEntry = {
  text: string
  readings: string[]
  senses: DictionarySense[]
}

type DictionaryEntryCardProps = {
  entry: DictionaryEntry
  fallbackWord: string
}

export default function DictionaryEntryCard({ entry, fallbackWord }: DictionaryEntryCardProps) {
  const kanaReadings = entry.readings.length > 0 ? entry.readings : [null]

  return (
    <div className={themeClasses.cardPadded}>
      <h2 className={themeClasses.heading2xl}>{entry.text || fallbackWord}</h2>

      {kanaReadings.map((reading, readingIndex) => (
        <div key={reading ?? `sense-${readingIndex}`} className={readingIndex > 0 ? 'mt-6' : 'mt-2'}>
          {reading && <p className="text-xl text-muted">{reading}</p>}
          <hr className={`my-4 ${themeClasses.divider}`} />

          {entry.senses.length === 0 ? (
            <p className="text-sm text-muted">No definitions available.</p>
          ) : (
            <div className="space-y-4">
              {entry.senses.map((sense, senseIndex) => (
                <div key={senseIndex}>
                  {sense.tags.length > 0 && (
                    <span className={themeClasses.badge}>{sense.tags.join('-')}</span>
                  )}
                  <ul className="mt-2 space-y-1">
                    {sense.definitions.map((definition, definitionIndex) => (
                      <li key={definitionIndex} className={themeClasses.definitionItem}>
                        {definition}
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
          )}
        </div>
      ))}
    </div>
  )
}
