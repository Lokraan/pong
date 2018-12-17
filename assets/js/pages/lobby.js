import MainView from './main'

import socket from "../socket"
import LobbySocket from "../lib/lobbySocket"

export default class PageLobbyView extends MainView {
  init() {
    this.lobby = null
  }

  mount() {
    super.mount()
  
    this.lobby = LobbySocket.init(socket)
    console.log("LobbyView mounted")
  }

  unmount() {
    super.unmount()

    this.lobby.disconnect()
    console.log("LobbyView unmounted")
  }
}
