ScoutSublimeVideo.Helpers.Text =

  truncate_middle: (text, options = { length: 30, omission: "..." }) ->
    if text
      if text.length <= options['length']
        text
      else
        side_length = Math.floor((options['length'] - options['omission'].length) / 2)
        console.log side_length
        leftPart  = text.substring(0, side_length + 1)
        rightPart = text.substring(text.length - side_length)
        console.log leftPart
        console.log rightPart
        leftPart + options['omission'] + rightPart
