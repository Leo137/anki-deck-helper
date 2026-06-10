/**
 * Shared Tailwind class compositions for the app theme.
 * Color tokens are defined in `index.css` under `@theme` and `.dark`.
 */
export const themeClasses = {
  heading: 'text-foreground',
  headingLg: 'text-lg font-medium text-foreground',
  headingXl: 'text-2xl font-semibold text-foreground',
  heading2xl: 'text-3xl font-semibold text-foreground',

  link: 'text-primary hover:underline',
  linkSm: 'text-sm text-primary hover:underline',

  card: 'rounded-lg border border-border bg-elevated shadow-sm',
  cardPadded: 'rounded-lg border border-border bg-elevated px-6 py-5 shadow-sm',
  cardDashed: 'rounded-lg border border-dashed border-border-input bg-elevated',
  panel: 'rounded-lg border border-border bg-elevated p-6 shadow-sm',

  alertError: 'rounded-lg border border-error-border bg-error-bg px-4 py-3 text-error-foreground',

  tag: 'rounded-full bg-tag px-2 py-0.5 font-mono text-xs text-tag-foreground',
  tagSm: 'rounded-full bg-tag px-2 py-0.5 font-mono text-sm text-tag-foreground',
  badge: 'inline-block rounded-md bg-tag px-2 py-0.5 font-mono text-xs font-medium text-tag-foreground',
  wordSetPill: 'rounded-full bg-primary/10 px-3 py-1 text-sm text-primary hover:bg-primary/20',

  input:
    'w-full rounded-lg border border-border-input bg-elevated px-3 py-2 text-sm text-foreground placeholder:text-muted focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20',
  iconButton:
    'shrink-0 rounded-lg border border-border-input bg-elevated p-2 text-secondary transition hover:bg-hover',
  dropdownPanel:
    'absolute top-full z-50 mt-1 max-h-80 w-full overflow-y-auto rounded-lg border border-border bg-elevated py-2 shadow-lg',
  dropdownItem:
    'flex w-full items-center justify-between rounded-md px-3 py-2 text-left text-sm hover:bg-hover',
  dropdownItemWithGap:
    'flex w-full items-center justify-between gap-3 rounded-md px-3 py-2 text-left text-sm hover:bg-hover',

  tableShell: 'overflow-hidden rounded-lg border border-border bg-elevated shadow-sm',
  table: 'min-w-full divide-y divide-divider',
  tableHead: 'bg-subtle-bg',
  tableBody: 'divide-y divide-divider',
  tableRowHover: 'hover:bg-hover/50',

  paginationNavButton:
    'rounded border border-border-input bg-elevated px-2 py-1 text-xs text-secondary enabled:hover:bg-hover disabled:cursor-not-allowed disabled:opacity-50',
  paginationPageButton:
    'min-w-7 rounded border border-border-input bg-elevated px-1 py-0.5 text-xs tabular-nums text-secondary hover:bg-hover',
  paginationPageActive:
    'min-w-7 rounded border border-primary bg-primary px-1 py-0.5 text-xs font-medium tabular-nums text-on-primary',

  header: 'border-b border-border bg-elevated',

  listPanel: 'divide-y divide-divider rounded-lg border border-border',
  listItemLabel: 'font-medium text-foreground',
  divider: 'border-border',

  wordSetCard:
    'block rounded-lg border border-border bg-elevated p-5 shadow-sm transition hover:border-primary hover:shadow-md',

  definitionItem:
    "text-sm leading-relaxed text-muted before:mr-1 before:text-subtle before:content-['*']",
} as const

export type ThemeClassKey = keyof typeof themeClasses

/** Semantic color token names (maps to `--color-*` in index.css). */
export const themeColorTokens = [
  'primary',
  'primary-hover',
  'on-primary',
  'surface',
  'elevated',
  'subtle-bg',
  'hover',
  'foreground',
  'secondary',
  'muted',
  'subtle',
  'border',
  'border-input',
  'divider',
  'tag',
  'tag-foreground',
  'error-bg',
  'error-border',
  'error-foreground',
] as const

export type ThemeColorToken = (typeof themeColorTokens)[number]
