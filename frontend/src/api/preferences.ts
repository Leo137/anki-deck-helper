import type { UserPreferences } from '../types/auth'
import { request } from './client'

export function fetchPreferences(): Promise<UserPreferences> {
  return request<UserPreferences>('/api/v1/users/preferences')
}

export function updatePreferences(preferredLanguage: string): Promise<UserPreferences> {
  return request<UserPreferences>('/api/v1/users/preferences', {
    method: 'PATCH',
    body: { preferences: { preferred_language: preferredLanguage } },
  })
}
