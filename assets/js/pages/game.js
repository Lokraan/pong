import MainView from './main';

import socket from "../socket"
import GameSocket from "../lib/gameSocket"

export default class PageGameView extends MainView {
  mount() {
    super.mount()
  
    this.game = GameSocket.init(socket, `game:${window.gameId}`)
    console.log("GameView mounted")
  }

  unmount() {
    super.unmount()

    this.game.disconnect()
    console.log("GameView unmounted")
  }
}
