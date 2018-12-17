const Lobby = {
  init(socket) {
    this.socket = socket

    this.findLobby()
  },

  findLobby() {
    this.findLobby = this.socket.channel("lobby:find")
      .receive("ok", (lobby_id) => {
        joinLobby(lobby_id)
        this.findLobby.leave()
      })
  },

  joinLobby(lobby_id) {
    this.lobbyChannel = this.socket.channel(lobby_id)
    this.lobbyChannel.join()
      .receive("ok", (resp) => {
        console.log("Joined! ", resp)
        this.bind()
      })
      .receive("error", (reason) => {
        console.log(reason)
        if(reason == "full") {
          findLobby()
        }
      })
  },

  disconnect() {
    if(this.lobbyChannel)
      this.lobbyChannel.leave()

    if(this.findLobby)
      this.findLobby.leave()
  },

  bind() {
    this.forceStart = document.getElementById("force-start")

    this.lobbyChannel.on("force_start:upvote", () => {
      const split = this.forceStart.innerHTML.split("/")
      const votes = parseInt(split[0]) + 1
      this.forceStart.innerHTML = `${votes}/6`
    })

    this.lobbyChannel.on("force_start:downvote", () => {
      const split = this.forceStart.innerHTML.split("/")
      const votes = parseInt(split[0]) - 1
      this.forceStart.innerHTML = `${votes}/6`
    })

    this.lobbyChannel.on("game:start", (game_id) => {
      const host = window.location.hostname
      const redir = `${host}/game/${game_id}`

      window.location.replace(redir)
    })

    this.forceStart.addEventListener("click", (e) => {
      e.preventDefault()
      this.lobbyChannel.push("force_start:upvote", {})
    })
  }
}

