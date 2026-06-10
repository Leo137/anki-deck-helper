import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { fetchPreferences, updatePreferences } from '../api/preferences'
import { useAuth } from '../contexts/AuthContext'
import { themeClasses } from '../styles/theme'
import { languageLabel } from '../utils/languageLabels'

export default function PreferencesPage() {
  const { user, loading: authLoading, refreshUser } = useAuth()
  const [availableLanguages, setAvailableLanguages] = useState<string[]>([])
  const [preferredLanguage, setPreferredLanguage] = useState('en')
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [saved, setSaved] = useState(false)

  useEffect(() => {
    if (!user) return

    setLoading(true)
    setError(null)

    fetchPreferences()
      .then((preferences) => {
        setPreferredLanguage(preferences.preferred_language)
        setAvailableLanguages(preferences.available_languages)
      })
      .catch((err: Error) => setError(err.message))
      .finally(() => setLoading(false))
  }, [user])

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setSaving(true)
    setError(null)
    setSaved(false)

    try {
      const preferences = await updatePreferences(preferredLanguage)
      setPreferredLanguage(preferences.preferred_language)
      await refreshUser()
      setSaved(true)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed')
    } finally {
      setSaving(false)
    }
  }

  if (authLoading) {
    return <p className="text-muted">Loading…</p>
  }

  if (!user) {
    return (
      <div>
        <Link to="/" className={themeClasses.linkSm}>
          ← Back to home
        </Link>
        <p className="mt-4 text-muted">Log in to manage your preferences.</p>
      </div>
    )
  }

  if (loading) {
    return <p className="text-muted">Loading preferences…</p>
  }

  return (
    <div>
      <Link to="/" className={themeClasses.linkSm}>
        ← Back to home
      </Link>

      <h1 className={`mt-4 ${themeClasses.headingXl}`}>Preferences</h1>
      <p className="mt-2 text-muted">Choose your default definition language for word pages.</p>

      <form onSubmit={handleSubmit} className={`mt-6 max-w-md ${themeClasses.panel}`}>
        <label className="block text-sm font-medium text-foreground" htmlFor="preferred-language">
          Preferred definition language
          <select
            id="preferred-language"
            value={preferredLanguage}
            onChange={(event) => setPreferredLanguage(event.target.value)}
            className={`mt-2 ${themeClasses.select}`}
          >
            {availableLanguages.map((code) => (
              <option key={code} value={code}>
                {languageLabel(code)}
              </option>
            ))}
          </select>
        </label>

        {error && <div className={`mt-4 ${themeClasses.alertError}`}>{error}</div>}
        {saved && <p className="mt-4 text-sm text-primary">Preferences saved.</p>}

        <button
          type="submit"
          disabled={saving}
          className="mt-4 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-on-primary hover:bg-primary-hover disabled:opacity-50"
        >
          {saving ? 'Saving…' : 'Save preferences'}
        </button>
      </form>
    </div>
  )
}
