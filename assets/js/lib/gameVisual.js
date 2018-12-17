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

const Visual = {
  init(canvas_id) {
    this.canvas = document.getElementById(canvas_id)

    return this
  },

  update(data) {
    const xtx = this.canvas.getContext("2d");

    console.log(data);

    // const x = data.x;
    // const y = data.y;
    // ctx.fillStyle = data.color;

    // if(type == "player") {
    //   const width = data.width;
    //   const height = data.height;

    //   ctx.translate(x + width/2, y + height/2);
    //   ctx.rotate(data.angle * Math.PI / 180);
    //   ctx.fillRect(-width/2, -height/2, width, height);
    // } else if(type == "ball") {
    //   ctx.beginPath();
    //   ctx.arc(x, y, data.size, 0, 2 * Math.PI);
    //   ctx.fill();
    // }
  },

  drawBalls(balls) {
    
  },

  drawPlayers() {

  }
}

function updateCanvas(data) {
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

export default Visual
