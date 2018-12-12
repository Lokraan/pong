import MainView    from './pages/main'
import PageLobbyView from './pages/lobby'
import PageGameView from './pages/game'

// Collection of specific view modules
const views = {
  PageLobbyView,
  PageGameView
}

export default function loadView(viewName) {
  return views[viewName] || MainView
}
