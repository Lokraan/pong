const LobbySocket = {
  init(socket) {
    this.socket = socket

    this.findLobby()

    return this
  },

  findLobby() {
    this.findLobbyChannel = this.socket.channel("lobby:find")
    this.findLobbyChannel.join()
      .receive("ok", (lobby_id) => {
        this.joinLobby(lobby_id)
        this.findLobbyChannel.leave()
      })
  },

  joinLobby(lobby_id) {
    this.lobbyChannel = this.socket.channel(lobby_id)

    const wow = this    
    this.lobbyChannel.join()
      .receive("ok", (resp) => {
        console.log(`Lobby joined ${resp}`)
        if(resp.game_id) {
          const redir = `/game/${resp.game_id}`
          window.location.replace(redir)
        }

        wow.bind()
      })
      .receive("error", (reason) => {
        console.log(`Lobby ${reason}`)
        if(reason == "full") {
          wow.findLobby()
        }
      })
  },

  disconnect() {
    console.log("disconnect")
    if(this.lobbyChannel)
      this.lobbyChannel.push("lobby:leave", {})
        .receive("ok", (resp) => console.log(resp, "disconnect2"))

    if(this.findLobbyChannel.state != "closed")
      this.findLobbyChannel.push("lobby:leave", {})
        .receive("ok", (resp) => console.log(resp, "disconnect3"))
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

    this.lobbyChannel.on("game:start", (data) => {
      const redir = `/game/${data.game_id}`

      window.location.replace(redir)
    })

    this.forceStart.addEventListener("click", (e) => {
      e.preventDefault()
      this.lobbyChannel.push("force_start:upvote", {})
    })
  }
}

export default LobbySocket
