const AUTH_TOKEN_KEY = 'auth_token'

let authToken: string | null = localStorage.getItem(AUTH_TOKEN_KEY)

function setAuthToken(token: string | null) {
  authToken = token
  if (token) {
    localStorage.setItem(AUTH_TOKEN_KEY, token)
  } else {
    localStorage.removeItem(AUTH_TOKEN_KEY)
  }
}

function getAuthToken(): string | null {
  return authToken
}

type RequestOptions = {
  method?: string
  body?: unknown
  auth?: boolean
}

async function request<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { method = 'GET', body, auth = true } = options
  const headers = new Headers({ Accept: 'application/json' })

  if (body !== undefined) {
    headers.set('Content-Type', 'application/json')
  }

  if (auth && authToken) {
    headers.set('Authorization', authToken)
  }

  const response = await fetch(path, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  })

  if (!response.ok) {
    let message = response.status === 404 ? 'Not found' : `Request failed (${response.status})`

    try {
      const errorBody = (await response.json()) as { error?: string; errors?: string[] }
      if (errorBody.errors?.length) {
        message = errorBody.errors.join(', ')
      } else if (errorBody.error) {
        message = errorBody.error
      }
    } catch {
      // Keep the default message when the body is not JSON.
    }

    throw new Error(message)
  }

  if (response.status === 204) {
    return undefined as T
  }

  const token = response.headers?.get?.('Authorization')
  if (token) {
    setAuthToken(token)
  }

  return response.json() as Promise<T>
}

export { AUTH_TOKEN_KEY, getAuthToken, request, setAuthToken }
