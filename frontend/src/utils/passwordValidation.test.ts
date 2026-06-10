import { describe, expect, it } from 'vitest'
import { isValidPassword, passwordValidationError } from './passwordValidation'

describe('passwordValidation', () => {
  it('accepts passwords with uppercase and special characters', () => {
    expect(isValidPassword('Password1!')).toBe(true)
    expect(passwordValidationError('Password1!')).toBeNull()
  })

  it('rejects short passwords', () => {
    expect(isValidPassword('Pass1!')).toBe(false)
  })

  it('rejects passwords without uppercase letters', () => {
    expect(isValidPassword('password1!')).toBe(false)
  })

  it('rejects passwords without special characters', () => {
    expect(isValidPassword('Password1')).toBe(false)
  })

  it('requires a password value', () => {
    expect(passwordValidationError('')).toBe('Password is required')
  })
})
