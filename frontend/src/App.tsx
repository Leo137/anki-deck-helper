import { Navigate, Route, Routes } from 'react-router-dom'
import Layout from './components/Layout'
import CreateDeckPage from './pages/CreateDeckPage'
import DeckCardDetailPage from './pages/DeckCardDetailPage'
import DeckPage from './pages/DeckPage'
import DecksPage from './pages/DecksPage'
import PreferencesPage from './pages/PreferencesPage'
import WordSetPage from './pages/WordSetPage'
import WordDetailPage from './pages/WordDetailPage'
import WordSetsPage from './pages/WordSetsPage'

export default function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Navigate to="/word-sets" replace />} />
        <Route path="/word-sets" element={<WordSetsPage />} />
        <Route path="/word-sets/:id" element={<WordSetPage />} />
        <Route path="/decks" element={<DecksPage />} />
        <Route path="/decks/new" element={<CreateDeckPage />} />
        <Route path="/decks/:id" element={<DeckPage />} />
        <Route path="/decks/:deckId/cards/:id" element={<DeckCardDetailPage />} />
        <Route path="/words/:id" element={<WordDetailPage />} />
        <Route path="/preferences" element={<PreferencesPage />} />
      </Routes>
    </Layout>
  )
}
