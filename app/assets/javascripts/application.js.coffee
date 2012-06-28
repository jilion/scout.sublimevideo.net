#= require jquery
# require jquery_ujs
#= require underscore
#= require jshashtable-2.1
#= require jquery.numberformatter-1.2.3.min
#
#= require_self
#= require_tree .

$.fn.exists = -> @length > 0

window.ScoutSublimeVideo =
  Helpers: {}

$(document).ready ->
  if $('#carousel').exists()
    $(document).on 'keydown', (event) =>
      unless event.metaKey
        switch event.which
          when ScoutSublimeVideo.Helpers.Keyboard.up
            ScoutSublimeVideo.submitForm('#backward', event)
          when ScoutSublimeVideo.Helpers.Keyboard.down
            ScoutSublimeVideo.submitForm('#forward', event)
          when ScoutSublimeVideo.Helpers.Keyboard.v
            if /new/.test(document.location.pathname)
              document.location = document.location.pathname.replace('new', 'active')
            else
              document.location = document.location.pathname.replace('active', 'new')
          when ScoutSublimeVideo.Helpers.Keyboard.t
            now = new Date
            document.location = document.location.href.replace(/\d{4}\-\d{2}\-\d{2}/, "#{now.getFullYear()}-#{now.getMonth()}-#{now.getDate()}")

window.ScoutSublimeVideo.submitForm = (formId, event) ->
  event.preventDefault()
  $(formId).submit()
  