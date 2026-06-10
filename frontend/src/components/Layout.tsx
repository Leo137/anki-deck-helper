import { Link } from 'react-router-dom'
import ThemeToggle from './ThemeToggle'

type LayoutProps = {
  children: React.ReactNode
}

export default function Layout({ children }: LayoutProps) {
  return (
    <div className="min-h-dvh bg-surface">
      <header className="border-b border-gray-200 bg-elevated dark:border-gray-700">
        <div className="mx-auto flex max-w-5xl items-center gap-4 px-4 py-4">
          <Link to="/" className="shrink-0 text-xl font-semibold text-primary hover:text-primary-hover">
            Word Tracker
          </Link>
          <ThemeToggle />
        </div>
      </header>
      <main className="mx-auto max-w-5xl px-4 py-8">{children}</main>
    </div>
  )
}
