export type User = {
  id: number
  email: string
  username: string
  preferred_language: string
}

export type UserPreferences = {
  preferred_language: string
  available_languages: string[]
}

export type SignupPayload = {
  email: string
  username: string
  password: string
  password_confirmation: string
}

export type LoginPayload = {
  email: string
  password: string
}
