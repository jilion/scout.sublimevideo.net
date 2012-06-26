ScoutSublimeVideo.Helpers.Keyboard =
  space: 32
  left: 37
  up: 38
  right: 39
  down: 40
  v: 86
  t: 84
  g: 71
  a: 65

  isUp: (e) ->
    e.keyCode is ScoutSublimeVideo.Helpers.Keyboard.up

  isDown: (e) ->
    e.keyCode is ScoutSublimeVideo.Helpers.Keyboard.down

  isLeft: (e) ->
    e.keyCode is ScoutSublimeVideo.Helpers.Keyboard.left

  isRight: (e) ->
    e.keyCode is ScoutSublimeVideo.Helpers.Keyboard.right

  isSpace: (e) ->
    e.keyCode is ScoutSublimeVideo.Helpers.Keyboard.space

ScoutSublimeVideo.Helpers.Keyboard.keysMap =
  32: 'space'
  37: 'left'
  38: 'up'
  39: 'right'
  40: 'down'
