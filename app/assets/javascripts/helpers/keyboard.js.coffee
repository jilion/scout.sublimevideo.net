ScoutSublimeVideo.Helpers.Keyboard =
  up: (e) ->
    ScoutSublimeVideo.Helpers.Keyboard.keysMap[e.keyCode] is 'up'

  down: (e) ->
    ScoutSublimeVideo.Helpers.Keyboard.keysMap[e.keyCode] is 'down'

  left: (e) ->
    ScoutSublimeVideo.Helpers.Keyboard.keysMap[e.keyCode] is 'left'

  right: (e) ->
    ScoutSublimeVideo.Helpers.Keyboard.keysMap[e.keyCode] is 'right'

  space: (e) ->
    ScoutSublimeVideo.Helpers.Keyboard.keysMap[e.keyCode] is 'space'

ScoutSublimeVideo.Helpers.Keyboard.keysMap =
  32: 'space'
  37: 'left'
  38: 'up'
  39: 'right'
  40: 'down'
