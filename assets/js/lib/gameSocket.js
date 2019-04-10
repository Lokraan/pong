import Visual from "./gameVisual"

const Game = {
  init(socket, game_id) {
    this.commands = {
      "w": "rotate_right",
      "s": "rotate_left",
      "a": "move_left", 
      "d": "move_right"
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

    this.gameChannel.on("game:end", (data) => {
      $("#gameEndModal").modal("show")

      $("#gameEndModal").on('hide.bs.modal', function (e) {
        window.location.replace("/")
      })
      
      console.log("game:end", data)
      this.gameChannel.leave()
    })

    window.addEventListener("keypress", (e) => {
      const key = e.key
      if(key in this.commands) {
        const command = {
          command: this.commands[key],
          type: "press"
        }

        this.gameChannel.push("game:command", command)
          .receive("ok", (reasons) => console.log(reasons))
          .receive("error", (reasons) => console.log(reasons))
      }
    })

    window.addEventListener("keyup", (e) => {
      const key = e.key
      console.log(e, key, "keyup")
      if(key in this.commands) {
        const command = {
          command: this.commands[key],
          type: "release"
        }

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
