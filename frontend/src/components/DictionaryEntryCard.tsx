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
    <div className="rounded-lg border border-gray-200 bg-elevated px-6 py-5 shadow-sm dark:border-gray-700">
      <h2 className="text-3xl font-semibold text-gray-900 dark:text-gray-100">{entry.text || fallbackWord}</h2>

      {kanaReadings.map((reading, readingIndex) => (
        <div key={reading ?? `sense-${readingIndex}`} className={readingIndex > 0 ? 'mt-6' : 'mt-2'}>
          {reading && <p className="text-xl text-muted">{reading}</p>}
          <hr className="my-4 border-gray-200 dark:border-gray-700" />

          {entry.senses.length === 0 ? (
            <p className="text-sm text-muted">No definitions available.</p>
          ) : (
            <div className="space-y-4">
              {entry.senses.map((sense, senseIndex) => (
                <div key={senseIndex}>
                  {sense.tags.length > 0 && (
                    <span className="inline-block rounded-md bg-gray-100 px-2 py-0.5 font-mono text-xs font-medium text-gray-700 dark:bg-gray-800 dark:text-gray-300">
                      {sense.tags.join('-')}
                    </span>
                  )}
                  <ul className="mt-2 space-y-1">
                    {sense.definitions.map((definition, definitionIndex) => (
                      <li
                        key={definitionIndex}
                        className="text-sm leading-relaxed text-muted before:mr-1 before:text-gray-400 before:content-['*'] dark:before:text-gray-500"
                      >
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
