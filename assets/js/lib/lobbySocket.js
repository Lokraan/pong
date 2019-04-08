const LobbySocket = {
  init(socket) {
    this.socket = socket

    this.lobbyStatus = document.getElementById("lobby-status")
    this.forceStart = document.getElementById("force-start")
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
        console.log("Lobby Joined", resp)
        this.lobbyStatus.innerHTML = `In Lobby ${lobby_id}`
        this.forceStart.innerHTML = `${resp.force_start_status}`

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
    this.lobbyChannel.on("force_start:update", (data) => {
      this.forceStart.innerHTML = `${data.force_start_status}`

      if(data.game_id) {
        const redir = `/game/${resp.game_id}`
        window.location.replace(redir)
      }
    })

    this.lobbyChannel.on("game:start", (data) => {
      const redir = `/game/${data.game_id}`

      window.location.replace(redir)
    })

    this.forceStart.addEventListener("click", (e) => {
      console.log("click click")
      e.preventDefault()
      this.lobbyChannel.push("force_start:upvote", {})
    })
  }
}

export default LobbySocket
