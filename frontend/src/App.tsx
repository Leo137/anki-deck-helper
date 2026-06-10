import { Route, Routes } from 'react-router-dom'
import Layout from './components/Layout'
import HomePage from './pages/HomePage'
import PreferencesPage from './pages/PreferencesPage'
import WordSetPage from './pages/WordSetPage'
import WordDetailPage from './pages/WordDetailPage'

export default function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/word-sets/:id" element={<WordSetPage />} />
        <Route path="/words/:id" element={<WordDetailPage />} />
        <Route path="/preferences" element={<PreferencesPage />} />
      </Routes>
    </Layout>
  )
}
