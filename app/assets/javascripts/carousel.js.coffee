class ScoutSublimeVideo.Carousel
  constructor: (@options) ->
    _.defaults @options,
      rows: 1, rowHeight: window.innerHeight / 3,
      cellRatio: 300 / 180, cellGap: 10,
      perspective: false, reflection: false,
      initialRepeatDelay: 330, repeatInterval: 60

    @cellHeight = Math.round(@options['rowHeight'])
    @cellWidth  = Math.round(@cellHeight * @options['cellRatio'])
    @cxspacing  = @cellWidth + @options['cellGap']
    @cyspacing  = @cellHeight + @options['cellGap']

    @dolly   = $('#dolly')
    @camera  = $('#camera')
    @stack   = $('#stack')
    @infoBar = $('#info_bar')
    @title   = $('h2.title')

    @cells            = []
    @currentCellIndex = -1
    @magnifyMode      = false
    @touchEnabled     = true

    @keys     = { left: false, right: false, up: false, down: false }
    @keyTimer = null
    console.log @options['images']
    if @options['images'] and @options['images'].length > 0
      this.addImages(@options['images'])
      this.updateStack(1)
    else
      console.log 'No images at initialization'

    this.setupKeyboardObservers()

  addImages: (images) ->
    _.each images, (image) =>
      this.addImage image

  addImage: (info) ->
    cell  = { info: info }
    cellIndex = @cells.length
    @cells.push(cell)

    col = Math.floor(cellIndex / @options['rows'])
    row = cellIndex - col * @options['rows']

    cell.div = $("<div class='cell fader view original' style='opacity: 0' data-stack-index='#{cellIndex}'></div>").css
      width: @cellWidth
      height: @cellHeight
      webkitTransform: this.translate3d(col * @cxspacing, row * @cyspacing, 0)

    img = $('<img />')

    img.on 'load', =>
      this.sizeAndPositionImageInCell(img, cell.div)
      cell.div.append $("<a class='mover viewflat' onclick='return false;'></a>").append(img[0])
      cell.div.append $("<a class='external_link' href='#{cell.info.link}'>#{cell.info.hostname}</a>")
      cell.div.append $("<ul class='info'><li><span class='i_f'>v</span> <em>Views: #{$.formatNumber(cell.info.views, { format: "#,##0" })}</em></li><li><span class='i_f'>m</span> <em>Video tags: #{$.formatNumber(cell.info.video_tags, { format: "#,##0" })}</em></li></ul>")
      cell.div.css 'opacity', 1
      this.addCellToStack(cell, row)

    img.on 'error', =>
      img.attr 'src', '/no-screenshot.png'

    img.attr 'src', info.thumb

  addCellToStack: (cell, row) ->
    @stack.append(cell.div)
    this.addReflectionToCell(cell) if row is @options['rows'] - 1

  addReflectionToCell: (cell) ->
    if @options['reflection']
      $(cell.div).addClass 'reflection'

  updateStack: (newIndex) ->
    this.updateCurrentCell(newIndex)
    this.moveDollyToCellIndex(@currentCellIndex)
    this.applyPerspective()

  moveDollyToCellIndex: (cellIndex) ->
    @dolly.css 'webkitTransform', this.cameraTransformForCellIndex(cellIndex)

  applyPerspective: ->
    if @options['perspective']
      currentMatrix = new WebKitCSSMatrix document.defaultView.getComputedStyle(@dolly[0], null).webkitTransform
      targetMatrix  = new WebKitCSSMatrix @dolly.css('webkitTransform')

      dx    = currentMatrix.e - targetMatrix.e
      angle = Math.min(Math.max(dx / (@cxspacing * 1.0), -1), @options['rows']) * 45;

      @camera.css
        webkitTransform: "rotateY(#{angle}deg)"
        webkitTransitionDuration: '330ms'

      clearTimeout(@currentTimer) if @currentTimer

      @currentTimer = setTimeout ->
        @camera.css
          webkitTransform: 'rotateY(0)'
          webkitTransitionDuration: '5s'
      , 330

  sizeAndPositionImageInCell: (image, cell) ->
    imgWidth   = image[0].width
    imgHeight  = image[0].height
    cellWidth  = cell.width()
    cellHeight = cell.height()
    ratio      = Math.min(cellHeight / imgHeight, cellWidth / imgWidth)
    imgWidth  *= ratio
    imgHeight *= ratio

    image.css
      width:  "#{Math.round(imgWidth)}px"
      height: "#{Math.round(imgHeight)}px"
      left:   "#{Math.round((cellWidth - imgWidth) / 2)}px"
      top:    "#{Math.round((cellHeight - imgHeight) / 2)}px"

  updateCurrentCell: (newCellIndex) ->
    this.unselectCurrentCell()
    this.setCurrentCell(newCellIndex)
    this.selectCurrentCell()
    this.magnifyCurrentCell()

  unselectCurrentCell: ->
    if @currentCellIndex isnt -1
      @currentCell.div.removeClass 'selected magnify'

  setCurrentCell: (newCellIndex) ->
    @currentCellIndex = Math.min(Math.max(newCellIndex, 0), @cells.length - 1)
    @currentCell      = @cells[@currentCellIndex]

  selectCurrentCell: ->
    @currentCell.div.addClass 'selected'
    this.updateInfoBar()

  magnifyCurrentCell: ->
    if @magnifyMode
      @currentCell.div.addClass 'magnify'
      this.loadZoomedImage()

  loadZoomedImage: ->
    return if @currentCell.isZoomed or @currentCell.info.zoom is @currentCell.info.thumb

    clearTimeout(@zoomTimer) if @zoomTimer

    zoomImage = $('<img class="zoom" />')

    @zoomTimer = setTimeout =>
      zoomImage.load =>
        this.sizeAndPositionImageInCell(zoomImage, @currentCell.div)
        $(@currentCell.div.find('img')[0]).replaceWith(zoomImage)
        @currentCell.isZoomed = true

      zoomImage.attr 'src', @currentCell.info.zoom
      @zoomTimer = null
    , 2000

  cameraTransformForCellIndex: (cellIndex) ->
    x  = Math.floor(cellIndex / @options['rows'])
    y  = cellIndex - x * @options['rows']
    cx = (x + 0.5) * @cxspacing
    cy = (y + 0.5) * @cyspacing

    if @magnifyMode
      this.translate3d(-cx, -cy, 50)
    else
      this.translate3d(-cx, -cy, 0)

  translate3d: (x, y, z) -> "translate3d(#{x}px, #{y}px, #{z}px)"

  toggleMagnifyMode: ->
    @magnifyMode = not @magnifyMode
    this.updateStack(@currentCellIndex)
    this.toggleInfoBar()

  toggleInfoBar: ->
    @infoBar.toggle()
    @title.toggleClass 'small'

  updateInfoBar: ->
    @infoBar.find('a.site_link').html(@currentCell.info.hostname).attr 'href', @currentCell.info.link
    @infoBar.find('a.admin_link').attr 'href', "https://admin.sublimevideo.net/sites/#{@currentCell.info.token}/edit"
    @infoBar.find('li.views em').html "Views: #{@currentCell.info.views}"
    @infoBar.find('li.video_tags em').html "Video tags: #{@currentCell.info.video_tags}"

  openSiteLink: ->
    window.open(@infoBar.find('a.site_link').attr('href'))
    window.focus()

  openAdminLink: ->
    window.open(@infoBar.find('a.admin_link').attr('href'))
    window.focus()

  setupKeyboardObservers: ->
    # Limited keyboard support for now
    $(window).on 'keydown', (e) =>
      if ScoutSublimeVideo.Helpers.Keyboard.isSpace(e)
        this.toggleMagnifyMode()
      else
        @keys[ScoutSublimeVideo.Helpers.Keyboard.keysMap[e.keyCode]] = true

      this.keyCheck()

    $(window).on 'keyup', (e) =>
      @keys[ScoutSublimeVideo.Helpers.Keyboard.keysMap[e.keyCode]] = false
      this.keyCheck()

    @camera.on 'click', (e) =>
      this.updateStack($(e.target).parents('.cell').data('stack-index'))
      this.toggleMagnifyMode()

    @camera[0].addEventListener 'touchstart', (e) =>
      e.preventDefault()
      @touchZoom = e.touches[1] isnt undefined
      @startX = e.touches[0].pageX
      @lastX = @startX
      false
    , false

    @camera[0].addEventListener 'touchmove', (e) =>
      e.preventDefault()
      return unless @touchEnabled

      if @touchZoom
        this.touchPrevented(=> this.toggleMagnifyMode()) if e.scale >= 1.5 or e.scale <= 0.5
      else
        @lastX = e.touches[0].pageX
        dx     = @lastX - @startX
        @keys.left  = (dx > 20)
        @keys.right = (dx < 20)
        this.keyCheck()
        @startX = @lastX
      false
    , true

    @camera[0].addEventListener 'touchend', (e) =>
      e.preventDefault()
      this.stopTouch()
      false
    , true

  touchPrevented: (block) ->
    @touchEnabled = false
    block()
    @touchEnabled = true

  stopTouch: ->
    @keys.left = @keys.right = false
    @startX = @lastX = 0

  updateKeys: ->
    newCellIndex = @currentCellIndex
    newCellIndex -= @options['rows'] if @keys.left and newCellIndex >= @options['rows']
    newCellIndex += @options['rows'] if @keys.right and (newCellIndex + @options['rows']) < @cells.length

    this.updateStack(newCellIndex) unless newCellIndex is @currentCellIndex

  repeatTimer: (delay) ->
    this.updateKeys()
    @keyTimer = setTimeout((=> this.repeatTimer(@options['repeatInterval'])), delay)

  keyCheck: ->
    if @keys.left or @keys.right or @keys.up or @keys.down
      this.repeatTimer(@options['initialRepeatDelay']) if @keyTimer is null
    else
      clearTimeout(@keyTimer)
      @keyTimer = null

  # snowstack_init();
  #     flickr(function (images)
  #     {
  # $.each(images, snowstack_addimage);
  # updateStack(1);
  #       loading = false;
  #     }, page);

# function flickr(callback, page)
# {
#     var url = "http://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=60746a125b4a901f2dbb6fc902d9a716&per_page=21&extras=url_o,url_m,url_s&page=" + page + "&format=json&jsoncallback=?";
#
#   $.getJSON(url, function(data)
#   {
#         var images = $.map(data.photos.photo, function (item)
#         {
#             return {
#               thumb: item.url_s,
#               zoom: 'http://farm' + item.farm + '.static.flickr.com/' + item.server + '/' + item.id + '_' + item.secret + '.jpg',
#               link: 'http://www.flickr.com/photos/' + item.owner + '/' + item.id
#             };
#         });
#
#         callback(images);
#     });
# }
