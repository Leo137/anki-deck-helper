import { themeClasses } from '../styles/theme'
import { languageLabel } from '../utils/languageLabels'

type DefinitionLanguagePickerProps = {
  languages: string[]
  value: string
  onChange: (language: string) => void
  disabled?: boolean
}

export default function DefinitionLanguagePicker({
  languages,
  value,
  onChange,
  disabled = false,
}: DefinitionLanguagePickerProps) {
  if (languages.length <= 1) {
    return null
  }

  const selectId = 'definition-language'

  return (
    <div className="flex items-center gap-2">
      <label htmlFor={selectId} className="text-sm font-medium text-muted">
        Definitions
      </label>
      <select
        id={selectId}
        value={value}
        disabled={disabled}
        onChange={(event) => onChange(event.target.value)}
        className={`${themeClasses.select} w-auto min-w-36 py-1.5`}
      >
        {languages.map((language) => (
          <option key={language} value={language}>
            {languageLabel(language)}
          </option>
        ))}
      </select>
    </div>
  )
}
