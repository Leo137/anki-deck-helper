async function request<T>(path: string): Promise<T> {
  const response = await fetch(path)

  if (!response.ok) {
    const message = response.status === 404 ? 'Not found' : `Request failed (${response.status})`
    throw new Error(message)
  }

  return response.json() as Promise<T>
}

export { request }
