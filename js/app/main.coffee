update = (delta, timeElapsed) ->
  player.update()

draw = ->
  context.drawCheckered 80, 0, 0, world.width, world.height
  player.draw()

setup = (first) ->
  world.resize canvas.width + 200, canvas.height + 200
  Actor::GRAVITY = false
  player = new Player()

player = undefined
keys =
  up: ["up", "w"]
  down: ["down", "s"]
  left: ["left", "a"]
  right: ["right", "d"]

preloadables = []
