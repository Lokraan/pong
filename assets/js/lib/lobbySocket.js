const LobbySocket = {
  init(socket) {
    this.socket = socket

    this.$lobbyStatus = $("#lobby-status")
    this.$forceStart = $("#force-start")
    this.$playerList = $("#player-list")

    this.findLobby()

    return this
  },

  updateLobbyStatus(d) {
    this.$lobbyStatus.empty()
    this.$lobbyStatus.text(`${d}`)
  },

  updateForceStart(d) {
    this.$forceStart.empty()
    this.$forceStart.text(`${d}`)
  },

  updatePlayerList(d) {
    this.$playerList.empty()
    
    for(let id in d) {
      const player = d[id]
      const li = $("<li class='list-group-item'></li>").text(player)

      this.$playerList.append(li)
    } 
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
        this.updateLobbyStatus(`In Lobby ${lobby_id}`)
        this.updateForceStart(resp.force_start_status)
        this.updatePlayerList(resp.players)

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
    if(this.lobbyChannel)
      this.lobbyChannel.push("lobby:leave", {})
        .receive("ok", (resp) => console.log(resp, "disconnect2"))

    if(this.findLobbyChannel.state != "closed")
      this.findLobbyChannel.push("lobby:leave", {})
        .receive("ok", (resp) => console.log(resp, "disconnect3"))
  },

  bind() {
    this.lobbyChannel.on("lobby:update", (data) => {
      if(data.force_start_status)
        this.updateForceStart(data.force_start_status)

      if(data.players)
        this.updatePlayerList(data.players)

      if(data.game_id) {
        const redir = `/game/${resp.game_id}`
        window.location.replace(redir)
      }
    })

    this.lobbyChannel.on("game:start", (data) => {
      const redir = `/game/${data.game_id}`

      window.location.replace(redir)
    })

    this.$forceStart.click((e) => {
      e.preventDefault()
      this.lobbyChannel.push("force_start:upvote", {})
    })
  }
}

export default LobbySocket
