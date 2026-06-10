import type { Pagination } from '../types/word'

type PaginationProps = {
  pagination: Pagination
  onPageChange: (page: number) => void
}

function pageRange(currentPage: number, totalPages: number, radius = 5): number[] {
  const start = Math.max(1, currentPage - radius)
  const end = Math.min(totalPages, currentPage + radius)
  return Array.from({ length: end - start + 1 }, (_, index) => start + index)
}

export default function PaginationControls({ pagination, onPageChange }: PaginationProps) {
  const { page, total_pages, total_count, per_page } = pagination

  if (total_pages <= 1) {
    return null
  }

  const start = (page - 1) * per_page + 1
  const end = Math.min(page * per_page, total_count)
  const pages = pageRange(page, total_pages)

  const navButtonClass =
    'rounded border border-gray-300 bg-elevated px-2 py-1 text-xs text-gray-700 enabled:hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50 dark:border-gray-600 dark:text-gray-200 dark:enabled:hover:bg-gray-800'

  const pageButtonClass =
    'min-w-7 rounded border border-gray-300 bg-elevated px-1 py-0.5 text-xs tabular-nums text-gray-700 hover:bg-gray-50 dark:border-gray-600 dark:text-gray-200 dark:hover:bg-gray-800'

  return (
    <div className="mt-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
      <p className="text-sm text-muted">
        Showing {start.toLocaleString()}–{end.toLocaleString()} of {total_count.toLocaleString()}{' '}
        words
      </p>
      <div className="flex flex-wrap items-center gap-1">
        <button
          type="button"
          disabled={page <= 1}
          onClick={() => onPageChange(page - 1)}
          className={navButtonClass}
        >
          Previous
        </button>
        <div className="flex items-center gap-0.5">
          {pages.map((pageNumber) => (
            <button
              key={pageNumber}
              type="button"
              aria-current={pageNumber === page ? 'page' : undefined}
              onClick={() => onPageChange(pageNumber)}
              className={
                pageNumber === page
                  ? 'min-w-7 rounded border border-primary bg-primary px-1 py-0.5 text-xs font-medium tabular-nums text-white'
                  : pageButtonClass
              }
            >
              {pageNumber}
            </button>
          ))}
        </div>
        <button
          type="button"
          disabled={page >= total_pages}
          onClick={() => onPageChange(page + 1)}
          className={navButtonClass}
        >
          Next
        </button>
      </div>
    </div>
  )
}
