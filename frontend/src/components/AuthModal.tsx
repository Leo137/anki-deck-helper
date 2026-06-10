import { useState, type FormEvent } from 'react'
import { useAuth } from '../contexts/AuthContext'
import { themeClasses } from '../styles/theme'
import { passwordValidationError } from '../utils/passwordValidation'

type AuthMode = 'login' | 'signup'

type AuthModalProps = {
  mode: AuthMode
  onClose: () => void
  onSwitchMode: (mode: AuthMode) => void
}

export default function AuthModal({ mode, onClose, onSwitchMode }: AuthModalProps) {
  const { login, signup } = useAuth()
  const [email, setEmail] = useState('')
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [passwordConfirmation, setPasswordConfirmation] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError(null)

    if (mode === 'signup') {
      const passwordError = passwordValidationError(password)
      if (passwordError) {
        setError(passwordError)
        return
      }
      if (password !== passwordConfirmation) {
        setError('Password confirmation does not match')
        return
      }
    }

    setSubmitting(true)
    try {
      if (mode === 'login') {
        await login({ email, password })
      } else {
        await signup({ email, username, password, password_confirmation: passwordConfirmation })
      }
      onClose()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4" role="presentation">
      <div
        className={`w-full max-w-md ${themeClasses.cardPadded}`}
        role="dialog"
        aria-modal="true"
        aria-labelledby="auth-modal-title"
      >
        <div className="flex items-start justify-between gap-4">
          <h2 id="auth-modal-title" className={themeClasses.headingLg}>
            {mode === 'login' ? 'Log in' : 'Create account'}
          </h2>
          <button type="button" onClick={onClose} className={themeClasses.iconButton} aria-label="Close">
            ✕
          </button>
        </div>

        <form className="mt-4 space-y-4" onSubmit={handleSubmit}>
          <label className="block text-sm font-medium text-foreground" htmlFor="auth-email">
            Email
            <input
              id="auth-email"
              type="email"
              required
              autoComplete="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              className={`mt-1 ${themeClasses.input}`}
            />
          </label>

          {mode === 'signup' && (
            <label className="block text-sm font-medium text-foreground" htmlFor="auth-username">
              Username
              <input
                id="auth-username"
                type="text"
                required
                autoComplete="username"
                value={username}
                onChange={(event) => setUsername(event.target.value)}
                className={`mt-1 ${themeClasses.input}`}
              />
            </label>
          )}

          <div>
            <label className="block text-sm font-medium text-foreground" htmlFor="auth-password">
              Password
            </label>
            <input
              id="auth-password"
              type="password"
              required
              autoComplete={mode === 'login' ? 'current-password' : 'new-password'}
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              className={`mt-1 ${themeClasses.input}`}
            />
            {mode === 'signup' && (
              <p className="mt-1 text-xs text-muted">
                At least 8 characters, one uppercase letter, and one special character.
              </p>
            )}
          </div>

          {mode === 'signup' && (
            <label className="block text-sm font-medium text-foreground" htmlFor="auth-password-confirmation">
              Password confirmation
              <input
                id="auth-password-confirmation"
                type="password"
                required
                autoComplete="new-password"
                value={passwordConfirmation}
                onChange={(event) => setPasswordConfirmation(event.target.value)}
                className={`mt-1 ${themeClasses.input}`}
              />
            </label>
          )}

          {error && <div className={themeClasses.alertError}>{error}</div>}

          <button
            type="submit"
            disabled={submitting}
            className="w-full rounded-lg bg-primary px-4 py-2 text-sm font-medium text-on-primary hover:bg-primary-hover disabled:opacity-50"
          >
            {submitting ? 'Please wait…' : mode === 'login' ? 'Log in' : 'Sign up'}
          </button>
        </form>

        <p className="mt-4 text-center text-sm text-muted">
          {mode === 'login' ? (
            <>
              Need an account?{' '}
              <button type="button" onClick={() => onSwitchMode('signup')} className={themeClasses.link}>
                Sign up
              </button>
            </>
          ) : (
            <>
              Already have an account?{' '}
              <button type="button" onClick={() => onSwitchMode('login')} className={themeClasses.link}>
                Log in
              </button>
            </>
          )}
        </p>
      </div>
    </div>
  )
}
