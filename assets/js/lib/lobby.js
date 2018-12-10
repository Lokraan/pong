const Lobby = {
  init(socket, lobby_id) {
    this.socket = socket

    this.lobbyChannel = this.socket.channel(lobby_id)
    this.lobbyChannel.join()
      .receive("ok", (resp) => console.log("Joined! ", resp))

    this.bind()
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

      this.lobbyChannel.leave()
      
      window.location.replace(redir)
    })

    this.forceStart.addEventListener("click", (e) => {
      e.preventDefault()
      this.lobbyChannel.push("force_start:upvote", {})
    })
  }
}

export default Lobby
