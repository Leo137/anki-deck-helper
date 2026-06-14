import { NavLink } from 'react-router-dom'

const linkClass = ({ isActive }: { isActive: boolean }) =>
  [
    'rounded-md px-3 py-1.5 text-sm transition',
    isActive ? 'bg-primary/10 font-medium text-primary' : 'text-secondary hover:bg-hover hover:text-foreground',
  ].join(' ')

export default function MainNav() {
  return (
    <nav aria-label="Main" className="flex items-center gap-1">
      <NavLink to="/word-sets" className={linkClass}>
        Word Sets
      </NavLink>
      <NavLink to="/decks" className={linkClass}>
        Decks
      </NavLink>
    </nav>
  )
}
