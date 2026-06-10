const PASSWORD_FORMAT = /^(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$/

export const PASSWORD_REQUIREMENTS_MESSAGE =
  'Password must be at least 8 characters and include one uppercase letter and one special character'

export function isValidPassword(password: string): boolean {
  return PASSWORD_FORMAT.test(password)
}

export function passwordValidationError(password: string): string | null {
  if (!password) return 'Password is required'
  if (!isValidPassword(password)) return PASSWORD_REQUIREMENTS_MESSAGE
  return null
}
