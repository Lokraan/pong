import Visual from "./gameVisual"

const Game = {
  init(socket, game_id) {
    this.commands = {
      119: "rotate_right",
      114: "rotate_left",
      100: "move_right", 
      97: "move_left"
    }

    this.gameChannel = socket.channel(game_id)
    this.gameChannel.join()
      .receive("ok", (resp) => {
        console.log(`Game ${resp}`)
      })
      .receive("error", (resp) => {
        console.log(`Game ${resp}`)
      })

    this.gameVisual = new Visual("game") 
    this.bind()

    return this
  },

  bind() {
    this.gameChannel.on("game:update", (data) =>  {
      this.gameVisual.update(data)
    })

    this.gameChannel.on("game:end", () => {
      this.gameChannel.leave()
    })

    window.addEventListener("keypress", (e) => {
      if(e.keyCode in this.commands) {
        const command = {
          command: this.commands[e.keyCode],
          type: "press"
        }

        console.log(command);

        this.gameChannel.push("game:command", command)
          .receive("ok", (reasons) =>  console.log(reasons))
          .receive("error", (reasons) =>  console.log(reasons))
      }
    })

    window.addEventListener("keyup", (e) => {
      if(e.keyCode in this.commands) {
        const command = {
          command: this.commands[e.keyCode],
          type: "release"
        }

        console.log(command);
        
        this.gameChannel.push("game:command", command)
          .receive("ok", (reasons) =>  console.log(reasons))
          .receive("error", (reasons) =>  console.log(reasons))
      }
    })
  },

  disconnect() {
    if(this.gameChannel)
      this.gameChannel.push("game:leave", {})
        .receive("ok", (resp) => console.log(resp, "disconnect2")) 
  }
}

export default Game
