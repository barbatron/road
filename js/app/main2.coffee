# The main logic for your project goes in this file.

###
The Player object; an Actor controlled by user input.
###

###
Keys used for various directions.
###

###
An array of image file paths to pre-load.
###

###
A magic-named function where all updates should occur.

@param {Number} delta
The amount of time since the last update. Use this to smooth movement.
This has the same value as the global `App.physicsDelta`.
@param {Number} timeElapsed
The amount of time elapsed while animating. This is useful for time-based
movement and limiting the frequency of events. This has the same value as
the global `App.physicsTimeElapsed`.
###
update = (delta, timeElapsed) ->
  root.my.update delta, timeElapsed

###
A magic-named function where all drawing should occur.
###
draw = ->
  
  # Draw a background. This is just for illustration so we can see scrolling.
  context.drawCheckered 80, 0, 0, world.width, world.height
  player.draw()

###
A magic-named function for one-time setup.

@param {Boolean} first
true if the app is being set up for the first time; false if the app has
been reset and is starting over.
###
setup = (first) ->
  
  # Change the size of the playable area. Do this before placing items!
  world.resize canvas.width + 200, canvas.height + 200
  
  # Switch from side view to top-down.
  Actor::GRAVITY = false
  
  # Initialize the player.
  player = new Player()
player = undefined
keys =
  up: ["up", "w"]
  down: ["down", "s"]
  left: ["left", "a"]
  right: ["right", "d"]

preloadables = []
