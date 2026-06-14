import { useState } from 'react'
import { themeClasses } from '../styles/theme'
import AuthModal from './AuthModal'

type GuestAuthPromptProps = {
  title: string
  message: string
}

export default function GuestAuthPrompt({ title, message }: GuestAuthPromptProps) {
  const [modalMode, setModalMode] = useState<'login' | 'signup' | null>(null)

  return (
    <div className={`${themeClasses.cardPadded} space-y-4`}>
      <div>
        <h2 className={themeClasses.headingLg}>{title}</h2>
        <p className="mt-2 text-sm text-muted">{message}</p>
      </div>
      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => setModalMode('login')}
          className="rounded-lg border border-border-input bg-elevated px-4 py-2 text-sm text-secondary hover:bg-hover"
        >
          Log in
        </button>
        <button
          type="button"
          onClick={() => setModalMode('signup')}
          className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-on-primary hover:bg-primary-hover"
        >
          Sign up
        </button>
      </div>

      {modalMode ? (
        <AuthModal
          mode={modalMode}
          onClose={() => setModalMode(null)}
          onSwitchMode={(mode) => setModalMode(mode)}
        />
      ) : null}
    </div>
  )
}
