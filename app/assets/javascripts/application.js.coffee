#= require jquery
# require jquery_ujs
#= require underscore
#
#= require_self
#= require_tree .

$.fn.exists = -> @length > 0

window.ScoutSublimeVideo =
  Helpers: {}

$(document).ready ->
  $(document).on 'keydown', (event) =>
    unless event.metaKey
      switch event.which
        when 38
          ScoutSublimeVideo.submitForm('#backward', event)
        when 40
          ScoutSublimeVideo.submitForm('#forward', event)
        when 86
          if /new_sites/.test(document.location.pathname)
            document.location = document.location.pathname.replace('new_sites', 'new_active_sites')
          else
            document.location = document.location.pathname.replace('new_active_sites', 'new_sites')

window.ScoutSublimeVideo.submitForm = (formId, event) ->
  event.preventDefault()
  $(formId).submit()
  