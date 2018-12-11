import MainView    from './pages/main'
import PageLobbyView from './pages/lobby'

// Collection of specific view modules
const views = {
  PageLobbyView,
}

export default function loadView(viewName) {
  return views[viewName] || MainView
}
