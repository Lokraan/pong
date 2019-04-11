import MainView from './main'

import {socket, params} from "../socket"
import GameSocket from "../lib/gameSocket"

export default class PageGameView extends MainView {
  mount() {
    super.mount()
  
    this.game = GameSocket.init(params.user_id, socket, `game:${window.gameId}`)
    console.log("GameView mounted")
  }

  unmount() {
    super.unmount()

    this.game.disconnect()
    console.log("GameView unmounted")
  }
}
