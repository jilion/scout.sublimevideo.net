# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
# require jquery_ujs
#= require_tree .

$.fn.exists = -> @length > 0

window.ScoutSublimeVideo = {}

$(document).ready ->
  $(document).on 'keydown', (event) =>
    console.log event.which
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
  