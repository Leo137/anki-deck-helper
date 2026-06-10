import { themeClasses } from '../styles/theme'
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
          className={themeClasses.paginationNavButton}
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
                  ? themeClasses.paginationPageActive
                  : themeClasses.paginationPageButton
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
          className={themeClasses.paginationNavButton}
        >
          Next
        </button>
      </div>
    </div>
  )
}
