import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { themeClasses } from '../styles/theme'
import AuthModal from './AuthModal'

export default function AuthNav() {
  const { user, loading, logout } = useAuth()
  const [modalMode, setModalMode] = useState<'login' | 'signup' | null>(null)

  if (loading) {
    return <span className="shrink-0 text-sm text-muted">…</span>
  }

  return (
    <div className="flex shrink-0 items-center gap-2">
      {user ? (
        <>
          <Link to="/preferences" className={`${themeClasses.linkSm} hidden sm:inline`}>
            {user.username}
          </Link>
          <button
            type="button"
            onClick={() => logout()}
            className="rounded-lg border border-border-input bg-elevated px-3 py-1.5 text-sm text-secondary hover:bg-hover"
          >
            Log out
          </button>
        </>
      ) : (
        <>
          <button
            type="button"
            onClick={() => setModalMode('login')}
            className="rounded-lg border border-border-input bg-elevated px-3 py-1.5 text-sm text-secondary hover:bg-hover"
          >
            Log in
          </button>
          <button
            type="button"
            onClick={() => setModalMode('signup')}
            className="rounded-lg bg-primary px-3 py-1.5 text-sm font-medium text-on-primary hover:bg-primary-hover"
          >
            Sign up
          </button>
        </>
      )}

      {modalMode && (
        <AuthModal
          mode={modalMode}
          onClose={() => setModalMode(null)}
          onSwitchMode={(mode) => setModalMode(mode)}
        />
      )}
    </div>
  )
}
