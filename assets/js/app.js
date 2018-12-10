// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
import socket from "./socket"

import Lobby from "./lib/lobby"
import Game from "./lib/game"

const App = {
  init(socket) {
    this.socket = socket
    this.lobby = null
    this.game = null

    console.log("wow")
    this.bind()
  },

  bind() {
    console.log("woww", this.socket)
    this.socket.onMessage((data) => {
      console.log("wow OK", data)
      this.findLobbyChannel = this.socket.channel("lobby:find")
      this.findLobbyChannel.join()
        .receive("ok", (lobby_id) => {
          this.lobby = Lobby.init(this.socket, lobby_id)        
        })
    })

    this.socket.onMessage((data) => {
      console.log(data)
      this.game = Game.init(this.socket, game_id)
    })
  }
}

App.init(socket)
