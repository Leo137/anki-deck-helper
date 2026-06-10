import { Link } from 'react-router-dom'
import { themeClasses } from '../styles/theme'
import SearchBar from './SearchBar'
import ThemeToggle from './ThemeToggle'

type LayoutProps = {
  children: React.ReactNode
}

export default function Layout({ children }: LayoutProps) {
  return (
    <div className="min-h-dvh bg-surface">
      <header className={themeClasses.header}>
        <div className="mx-auto flex max-w-5xl items-center gap-4 px-4 py-4">
          <Link to="/" className="shrink-0 text-xl font-semibold text-primary hover:text-primary-hover">
            Word Tracker
          </Link>
          <SearchBar />
          <ThemeToggle />
        </div>
      </header>
      <main className="mx-auto max-w-5xl px-4 py-8">{children}</main>
    </div>
  )
}
