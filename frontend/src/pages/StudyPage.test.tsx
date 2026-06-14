import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Route, Routes } from 'react-router-dom'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as decksApi from '../api/decks'
import * as authApi from '../api/auth'
import { setAuthToken } from '../api/client'
import { renderWithProviders } from '../test/test-utils'
import StudyPage from './StudyPage'

const studyCard = {
  id: 10,
  position: 1,
  created_at: '',
  updated_at: '',
  deck: { id: 3, name: 'Favorites' },
  fields: [
    {
      id: 1,
      side: 'front' as const,
      html_content: '<h1>半導体</h1>',
      created_at: '',
      updated_at: '',
    },
    {
      id: 2,
      side: 'back' as const,
      html_content: '<div class="definition">* semiconductor</div>',
      created_at: '',
      updated_at: '',
    },
  ],
}

function renderStudyPage(route = '/decks/3/study') {
  renderWithProviders(
    <Routes>
      <Route path="/decks/:id/study" element={<StudyPage />} />
      <Route path="/decks/:id" element={<div>Deck page</div>} />
    </Routes>,
    { route },
  )
}

describe('StudyPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
    setAuthToken(null)
  })

  it('reveals the response and records a know answer', async () => {
    const user = userEvent.setup()
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(decksApi, 'fetchDeck').mockResolvedValue({
      id: 3,
      name: 'Favorites',
      status: 'ready',
      error_message: null,
      generation_progress: 100,
      generation_total: 1,
      cards_count: 1,
      created_at: '',
      updated_at: '',
    })
    vi.spyOn(decksApi, 'fetchStudyCard')
      .mockResolvedValueOnce(studyCard)
      .mockResolvedValueOnce({ ...studyCard, id: 11, position: 2 })
    const recordStudyResponse = vi.spyOn(decksApi, 'recordStudyResponse').mockResolvedValue({
      know_count: 1,
      dont_know_count: 0,
      total_responses: 1,
      accuracy_rate: 1,
      last_responded_at: '2026-06-14T12:00:00Z',
      last_correct: true,
    })

    renderStudyPage()

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: 'Study: Favorites' })).toBeInTheDocument()
    })

    expect(screen.getByText('半導体')).toBeInTheDocument()
    expect(screen.queryByText('semiconductor')).not.toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: /show response/i }))

    expect(screen.getByText(/semiconductor/)).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: /^know$/i }))

    await waitFor(() => {
      expect(recordStudyResponse).toHaveBeenCalledWith(3, { card_id: 10, correct: true })
    })
    await waitFor(() => {
      expect(decksApi.fetchStudyCard).toHaveBeenLastCalledWith(3, 10)
    })
  })

  it('ends the study session and returns to the deck page', async () => {
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(decksApi, 'fetchDeck').mockResolvedValue({
      id: 3,
      name: 'Favorites',
      status: 'ready',
      error_message: null,
      generation_progress: 100,
      generation_total: 1,
      cards_count: 1,
      created_at: '',
      updated_at: '',
    })
    vi.spyOn(decksApi, 'fetchStudyCard').mockResolvedValue(studyCard)

    renderStudyPage()

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /end study/i })).toBeInTheDocument()
    })

    await userEvent.click(screen.getByRole('button', { name: /end study/i }))

    await waitFor(() => {
      expect(screen.getByText('Deck page')).toBeInTheDocument()
    })
  })

  it('supports keyboard shortcuts for reveal and grading', async () => {
    const user = userEvent.setup()
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(decksApi, 'fetchDeck').mockResolvedValue({
      id: 3,
      name: 'Favorites',
      status: 'ready',
      error_message: null,
      generation_progress: 100,
      generation_total: 2,
      cards_count: 2,
      created_at: '',
      updated_at: '',
    })
    vi.spyOn(decksApi, 'fetchStudyCard')
      .mockResolvedValueOnce(studyCard)
      .mockResolvedValueOnce({ ...studyCard, id: 11, position: 2 })
    const recordStudyResponse = vi.spyOn(decksApi, 'recordStudyResponse').mockResolvedValue({
      know_count: 0,
      dont_know_count: 1,
      total_responses: 1,
      accuracy_rate: 0,
      last_responded_at: '2026-06-14T12:00:00Z',
      last_correct: false,
    })

    renderStudyPage()

    await waitFor(() => {
      expect(screen.getByText('半導体')).toBeInTheDocument()
    })

    await user.keyboard(' ')
    expect(screen.getByText(/semiconductor/)).toBeInTheDocument()

    await user.keyboard('1')

    await waitFor(() => {
      expect(recordStudyResponse).toHaveBeenCalledWith(3, { card_id: 10, correct: false })
    })
  })

  it('marks a card as know with 3 or space after revealing', async () => {
    const user = userEvent.setup()
    setAuthToken('Bearer test-token')
    vi.spyOn(authApi, 'fetchCurrentUser').mockResolvedValue({
      id: 1,
      email: 'reader@example.com',
      username: 'reader',
      preferred_language: 'en',
    })
    vi.spyOn(decksApi, 'fetchDeck').mockResolvedValue({
      id: 3,
      name: 'Favorites',
      status: 'ready',
      error_message: null,
      generation_progress: 100,
      generation_total: 1,
      cards_count: 1,
      created_at: '',
      updated_at: '',
    })
    vi.spyOn(decksApi, 'fetchStudyCard').mockResolvedValue(studyCard)
    const recordStudyResponse = vi.spyOn(decksApi, 'recordStudyResponse').mockResolvedValue({
      know_count: 1,
      dont_know_count: 0,
      total_responses: 1,
      accuracy_rate: 1,
      last_responded_at: '2026-06-14T12:00:00Z',
      last_correct: true,
    })

    renderStudyPage()

    await waitFor(() => {
      expect(screen.getByText('半導体')).toBeInTheDocument()
    })

    await user.keyboard(' ')
    await user.keyboard('3')

    await waitFor(() => {
      expect(recordStudyResponse).toHaveBeenCalledWith(3, { card_id: 10, correct: true })
    })
  })
})
