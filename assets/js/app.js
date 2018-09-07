// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

const socket = new Socket("/socket", {
  params: {token: window.userToken},
  logger: function(kind, msg, data){
    console.log(`${kind}: ${msg}`, data)
  }
})

const Lobby = {
  init() {
    socket.connect();
    this.findLobbyChannel = socket.channel("find:lobby");

    this.findLobbyChannel.join()
      .receive("ok", (lobby_id) => {
        this.lobbyChannel = socket.channel(lobby_id);
      });

    this.findLobbyChannel.leave();

    this.lobbyChannel.join()
      .receive("ok", (resp) => console.log("Joined! ", resp));
  },

  bind() {
    this.forceStart = document.getElemntById("force-start");
    this.lobbyChannel.on("game_id", (game_id) => {
      App.init(game_id);
      this.lobbyChannel.leave();
    });

    this.lobbyChannel.on("force_start_vote", (user) => {
      const split = this.forceStart.innerHTML.split("/");
      const votes = parseInt(split[0]);
      this.forceStart.innerHTML = `${votes}/6`
    });

    this.forceStart.addEventListener("click", (e) => {
      e.preventDefault();
      this.lobbyChannel.push("force_start_vote", {});
    });

  }
}

const App = {
  init(game_id) {
    socket.connect();
    this.gameChannel = socket.channel(game_id);   
  },

  bind() {
   this.gameChannel.on("move", (data) =>  {
    updateCanvas(data);
   });

   window.addEventListener("keypress", (e) => {
    switch(e.keyCode) {
      case 119:
        this.gameChannel.push("rotate_right");
          .receive("ok", onOk);
          .receive("error", onError);
          break;

      case 115:
        this.gameChannel.push("rotate_left");
          .receive("ok", onOk);
          .receive("error", onError);
        break;

      case 97:
        this.gameChannel.push("move_left");
          .receive("ok", onOk);
          .receive("error", onError);
        break;
        
      case 100:
        this.gameChannel.push("move_right");
          .receive("ok", onOk);
          .receive("error", onError);
        break;
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
