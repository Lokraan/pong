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

class Visual {
  constructor(canvas_id) {
    this.canvas = document.getElementById(canvas_id)
    this.canvas.width = 800
    this.canvas.height = 800

    return this
  }

  drawWall(ctx, wall) {
    ctx.strokeStyle = '#ffffff'
    ctx.lineWidth = 5

    ctx.beginPath()
    ctx.moveTo(wall.x0, wall.y0)
    ctx.lineTo(wall.x1, wall.y1)
    ctx.stroke() 
  }

  drawWalls(ctx, walls) {
    for(var i in walls) {      
      this.drawWall(ctx, walls[i])
    }
  }

  drawBall(ctx, ball) {
    ctx.beginPath()
    ctx.fillStyle = "yellow"
    ctx.arc(ball.x, ball.y, ball.radius, 0, 2 * Math.PI)
    ctx.fill()
  }

  drawBalls(ctx, balls) {
    for(var i in balls)
      this.drawBall(ctx, balls[i])
  }

  drawPlayer(ctx, player, color) {
    ctx.strokeStyle = color
    ctx.lineWidth = 5

    ctx.beginPath()
    ctx.moveTo(player.x0, player.y0)
    ctx.lineTo(player.x1, player.y1)
    ctx.stroke() 
  }

  drawPlayers(ctx, playerId, players) {
    for(var i in players) {
      const color = playerId == i ? "white" : "yellow"
      this.drawPlayer(ctx, players[i], color)
    }
  }

  update(playerId, data) {
    const ctx = this.canvas.getContext("2d")

    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    this.drawWalls(ctx, data.walls)
    this.drawBalls(ctx, data.balls)
    this.drawPlayers(ctx, playerId, data.players)
  }
}

export default Visual
