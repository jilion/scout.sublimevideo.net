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
            daysBack = if /active/.test document.location.href then 7 else 1
            pastDate = new Date(new Date() - (1000 * 3600 * 24 * daysBack)) # yesterday or last week
            document.location = document.location.href.replace /\d{4}\-\d{1,2}\-\d{1,2}/, "#{pastDate.getFullYear()}-#{pastDate.getMonth()+1}-#{pastDate.getDate()}"
          when ScoutSublimeVideo.Helpers.Keyboard.f
            $.ajax(
              type: 'POST'
              url: "/take/#{ScoutSublimeVideo.carousel.currentCell.info.token}"
            ).done (msg) ->
              alert(msg)

window.ScoutSublimeVideo.submitForm = (formId, event) ->
  event.preventDefault()
  $(formId).submit()

