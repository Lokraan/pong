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

const Lobby = {
  init() {
    socket.connect();
    this.findLobbyChannel = socket.channel("lobby:find_lobby");

    this.findLobbyChannel.join()
      .receive("ok", (lobby_id) => {
        this.lobbyChannel = socket.channel(lobby_id);
      });

    this.findLobbyChannel.leave();

    this.lobbyChannel.join()
      .receive("ok", (resp) => console.log("Joined! ", resp));
  },

  bind() {
    this.forceStart = document.getElementById("force-start");

    this.lobbyChannel.on("force_start_upvote", () => {
      const split = this.forceStart.innerHTML.split("/");
      const votes = parseInt(split[0]) + 1;
      this.forceStart.innerHTML = `${votes}/6`
    });

    this.lobbyChannel.on("force_start_downvote", () => {
      const split = this.forceStart.innerHTML.split("/");
      const votes = parseInt(split[0]) - 1;
      this.forceStart.innerHTML = `${votes}/6`
    });

    this.lobbyChannel.on("game_start", (game_id) => {
      const host = window.location.hostname;
      const redir = `${host}/game/${game_id}`

      App.init(game_id);
      this.lobbyChannel.leave();
      
      window.location.replace(redir);
    })

    this.forceStart.addEventListener("click", (e) => {
      e.preventDefault();
      this.lobbyChannel.push("force_start_upvote", {});
    });
  }
}

const App = {
  init(game_id) {
    socket.connect();
    this.gameChannel = socket.channel(game_id);
    this.commands = {
      119: "rotate_right",
      114: "rotate_left",
      100: "move_right", 
      97: "move_left"
    };
  },

  bind() {
    this.gameChannel.on("move", (data) =>  {
      updateCanvas(data);
    });

    window.addEventListener("keypress", (e) => {
      if(e.keyCode in this.commands) {
        this.gameChannel.push("command", {command: this.commands[e.keyCode]})
          .receive("ok", (reasons) =>  console.log(reasons))
          .receive("error", (reasons) =>  console.log(reasons));
      }
    });
  }
}

/*
 * %Data{
 *  type: "player", 
 *  x: 0,
 *  y: 0,
 *  width: 50,
 *  height: 15,
 *  angle: angle
 * }
 *
 */
function updateCanvas(data) {
  const canvas = document.getElemntById("game");
  const ctx = canvas.getContext("2d");
  
  const type = data.type;

  const x = data.x;
  const y = data.y;
  ctx.fillStyle = data.color;

  if(type == "player") {
    const width = data.width;
    const height = data.height;

    ctx.translate(x + width/2, y + height/2);
    ctx.rotate(data.angle * Math.PI / 180);
    ctx.fillRect(-width/2, -height/2, width, height);
  } else if(type == "ball") {
    ctx.beginPath();
    ctx.arc(x, y, data.size, 0, 2 * Math.PI);
    ctx.fill();
  }
}

if (window.userToken != "") Lobby.init();
