const Game = {
  init(game_id) {
    socket.connect()
    this.gameChannel = socket.channel(game_id)
    this.commands = {
      119: "rotate_right",
      114: "rotate_left",
      100: "move_right", 
      97: "move_left"
    }

    this.bind()
  },

  bind() {
    this.gameChannel.on("game:update", (data) =>  {
      updateCanvas(data)
    })

    this.gameChannel.on("game:end", () => {
      this.gameChannel.leave()
    })

    window.addEventListener("keypress", (e) => {
      if(e.keyCode in this.commands) {
        this.gameChannel.push("game:command", {command: this.commands[e.keyCode]})
          .receive("ok", (reasons) =>  console.log(reasons))
          .receive("error", (reasons) =>  console.log(reasons))
      }
    })
  }
}

export default Game
