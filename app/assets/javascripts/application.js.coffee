#= require jquery
# require jquery_ujs
#= require underscore
#= require jshashtable-2.1
#= require jquery.numberformatter-1.2.3.min
#= require mousetrap.min
#
#= require_self
#= require_tree .

$.fn.exists = -> @length > 0

window.ScoutSublimeVideo =
  Helpers: {}

$(document).ready ->
  if $('#carousel').exists()
    $(document).on 'keydown', (event) =>
      Mousetrap.bind 'up',   -> ScoutSublimeVideo.submitForm('#backward', event)
      Mousetrap.bind 'down', -> ScoutSublimeVideo.submitForm('#forward', event)
      Mousetrap.bind 'v',    ScoutSublimeVideo.toggleView
      Mousetrap.bind 't',    ScoutSublimeVideo.moveToYesterdayOrLastWeek
      Mousetrap.bind 'f',    ScoutSublimeVideo.toggleFullscreen
      Mousetrap.bind 'r',    ScoutSublimeVideo.retakeScreenshot

window.ScoutSublimeVideo.submitForm = (formId, event) ->
  event.preventDefault()
  $(formId).submit()

window.ScoutSublimeVideo.toggleView = ->
  if /new/.test(document.location.pathname)
    document.location = document.location.pathname.replace('new', 'active')
  else
    document.location = document.location.pathname.replace('active', 'new')

window.ScoutSublimeVideo.toggleFullscreen = ->
  if document.webkitIsFullScreen
    document.webkitCancelFullScreen() if document.webkitCancelFullScreen
  else
    document.body.webkitRequestFullScreen()

window.ScoutSublimeVideo.moveToYesterdayOrLastWeek = ->
  daysBack = if /active/.test document.location.href then 7 else 1
  pastDate = new Date(new Date() - (1000 * 3600 * 24 * daysBack)) # yesterday or last week
  document.location = document.location.href.replace /\d{4}\-\d{1,2}\-\d{1,2}/, "#{pastDate.getFullYear()}-#{pastDate.getMonth()+1}-#{pastDate.getDate()}"

window.ScoutSublimeVideo.retakeScreenshot = ->
  $.ajax(
    type: 'POST'
    url: "/take/#{ScoutSublimeVideo.carousel.currentCell.info.token}"
  ).done (msg) ->
    console.log msg

