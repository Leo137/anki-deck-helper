import { useTheme } from '../contexts/ThemeContext'

export default function ThemeToggle() {
  const { preference, resolvedTheme, cyclePreference } = useTheme()

  const label =
    preference === 'system'
      ? `Theme: system (${resolvedTheme}). Click to switch to light mode.`
      : preference === 'light'
        ? 'Theme: light. Click to switch to dark mode.'
        : 'Theme: dark. Click to switch to system preference.'

  return (
    <button
      type="button"
      onClick={cyclePreference}
      aria-label={label}
      title={label}
      className="shrink-0 rounded-lg border border-gray-300 bg-white p-2 text-gray-700 transition hover:bg-gray-50 dark:border-gray-600 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
    >
      {preference === 'system' && (
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" className="h-5 w-5" aria-hidden="true">
          <rect x="2" y="3" width="20" height="14" rx="2" />
          <path d="M8 21h8M12 17v4" />
        </svg>
      )}
      {preference === 'light' && (
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" className="h-5 w-5" aria-hidden="true">
          <circle cx="12" cy="12" r="4" />
          <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41" />
        </svg>
      )}
      {preference === 'dark' && (
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" className="h-5 w-5" aria-hidden="true">
          <path d="M21 14.5A8.5 8.5 0 1 1 9.5 3a6.5 6.5 0 1 0 11.5 11.5z" />
        </svg>
      )}
    </button>
  )
}
