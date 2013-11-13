class ScoutSublimeVideo.Carousel
  constructor: (@options = {}) ->
    _.defaults @options,
      rows: 1, rowHeight: window.innerHeight / 3,
      cellRatio: 1100 / 825, cellGap: 30,
      perspective: false, reflection: false,
      initialKeyRepeatDelay: 330, keyRepeatInterval: 60,
      slideshow: true, autoNextInterval: 5000, loop: true

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
    @keymap   = { 37: 'left', 38: 'up', 39: 'right', 40: 'down' };
    @keyTimer = null

    @slideshowTimer = null

    if @options['images'] and @options['images'].length > 0
      this.addImages(@options['images'])
      this.goTo(0)
      this.startSlideshow(@options['autoNextInterval'] * 2) if @options['slideshow'] and @options['images'].length >= 2
    else
      console.warn 'No images at initialization'

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
      cell.div.append $("<a class='external_link' href='#{cell.info.link}'>#{ScoutSublimeVideo.Helpers.Text.truncate_middle(cell.info.hostname, { length: 20 })}</a>")
      ul = $("<ul class='info'></ul>")
      ul.append $("<li class='views'><em data-icon='v'>Views: #{$.formatNumber(cell.info.views, { format: "#,##0" })}</em></li>")
      ul.append $("<li class='video_tags'><em data-icon='m'>Videos: #{$.formatNumber(cell.info.video_tags, { format: "#,##0" })}</em></li>")
      ul.append $("<li class='tags'><em data-icon='t'>#{cell.info.tags}</em></li>") unless cell.info.tags is ''
      cell.div.append ul
      cell.div.css 'opacity', 1
      this.addCellToStack(cell, row)

    img.on 'error', =>
      img.attr 'src', '/no-load.png'

    img.attr 'src', info.thumb

  addCellToStack: (cell, row) ->
    @stack.append(cell.div)
    this.addReflectionToCell(cell) if row is @options['rows'] - 1

  addReflectionToCell: (cell) ->
    if @options['reflection']
      $(cell.div).addClass 'reflection'

  goTo: (newIndex) ->
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
        webkitTransitionDuration: '50ms'

      clearTimeout(@currentTimer) if @currentTimer

      @currentTimer = setTimeout ->
        @camera.css
          webkitTransform: 'rotateY(0)'
          webkitTransitionDuration: '1s'
      , 50

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
    this.updatePageTitle()
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

  updatePageTitle: ->
    currentState = "#{@currentCellIndex + 1} / #{@cells.length}"
    if /\d+ \/ \d+/.test(document.title)
      document.title = document.title.replace /\d+ \/ \d+/, currentState
    else
      document.title = "#{document.title} - #{currentState}"

  magnifyCurrentCell: ->
    if @magnifyMode
      @currentCell.div.addClass 'magnify'
      this.loadZoomedImage()

  loadZoomedImage: ->
    return if @currentCell.isZoomed or !@currentCell.info.zoom or @currentCell.info.zoom is @currentCell.info.thumb

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
    cx = Math.floor((x + 0.5) * @cxspacing)
    cy = Math.floor((y + 0.5) * @cyspacing)

    if @magnifyMode
      this.translate3d(-cx, -cy, 50)
    else
      this.translate3d(-cx, -cy, 0)

  translate3d: (x, y, z) -> "translate3d(#{x}px, #{y}px, #{z}px)"

  toggleMagnifyMode: ->
    @magnifyMode = not @magnifyMode
    this.goTo(@currentCellIndex)
    this.toggleInfoBar()

  toggleInfoBar: ->
    @infoBar.toggle()
    @title.toggleClass 'small'

  updateInfoBar: ->
    @infoBar.find('a.site_link').text(@currentCell.info.hostname).attr 'href', @currentCell.info.link
    @infoBar.find('a.admin_link').attr 'href', "https://admin.sublimevideo.net/sites/#{@currentCell.info.token}/edit"
    @infoBar.find('li.views').html "<em data-icon='v'>Views: #{@currentCell.info.views}</em>"
    @infoBar.find('li.video_tags').html "<em data-icon='m'>Videos: #{@currentCell.info.video_tags}</em>"
    if @currentCell.info.tags is ''
      @infoBar.find('li.tags').text ''
    else
      @infoBar.find('li.tags').html "<em data-icon='t'>#{@currentCell.info.tags}</em>"

  openSiteLink: ->
    window.open(@infoBar.find('a.site_link').attr('href'))
    window.focus()

  openAdminLink: ->
    window.open(@infoBar.find('a.admin_link').attr('href'))
    window.focus()

  setupKeyboardObservers: ->
    # Limited keyboard support for now
    Mousetrap.bind 'space', => this.toggleMagnifyMode()
    Mousetrap.bind 'o', => this.openSiteLink()
    Mousetrap.bind 'a', => this.openAdminLink()
    Mousetrap.bind 's', => if @slideshowTimer then this.stopSlideshow() else this.startSlideshow(0)
    Mousetrap.bind ['left', 'right', 'up', 'down'], (event) =>
      @keys[@keymap[event.keyCode]] = true
      this.keyCheck()

    Mousetrap.bind ['left', 'right', 'up', 'down'], (event) =>
      @keys[@keymap[event.keyCode]] = false
      this.keyCheck()
    , 'keyup'

    @camera.on 'click', (event) =>
      this.goTo($(event.target).parents('.cell').data('stack-index'))
      this.toggleMagnifyMode()

    @camera[0].addEventListener 'touchstart', (event) =>
      event.preventDefault()
      @touchZoom = event.touches[1] isnt undefined
      @startX = event.touches[0].pageX
      @lastX = @startX
      false
    , false

    @camera[0].addEventListener 'touchmove', (event) =>
      event.preventDefault()
      return unless @touchEnabled

      if @touchZoom
        this.touchPrevented(=> this.toggleMagnifyMode()) if event.scale >= 1.5 or event.scale <= 0.5
      else
        @lastX = event.touches[0].pageX
        dx     = @lastX - @startX
        @keys['left']  = dx > 0 and dx > 20
        @keys['right'] = dx < 0 and dx < -20
        this.keyCheck()
        @startX = @lastX
      false
    , true

    @camera[0].addEventListener 'touchend', (event) =>
      event.preventDefault()
      this.stopTouch()
      false
    , true

  touchPrevented: (block) ->
    @touchEnabled = false
    block()
    @touchEnabled = true

  stopTouch: ->
    @keys['left'] = @keys['right'] = false
    @startX = @lastX = 0

  keyCheck: ->
    if @keys['left'] or @keys['right'] or @keys['up'] or @keys['down']
      this.repeatTimer(@options['initialKeyRepeatDelay']) if @keyTimer is null
    else
      this.killTimer('keyTimer')

  repeatTimer: (delay) ->
    this.updateKeys()
    @keyTimer = setTimeout((=> this.repeatTimer(@options['keyRepeatInterval'])), delay)

  updateKeys: ->
    newCellIndex  = @currentCellIndex
    newCellIndex -= @options['rows'] if @keys['left'] and newCellIndex >= @options['rows']
    newCellIndex += @options['rows'] if @keys['right'] and (newCellIndex + @options['rows']) < @cells.length

    unless newCellIndex is @currentCellIndex
      this.stopSlideshow()
      this.goTo(newCellIndex)

  autoNext: ->
    newCellIndex = @currentCellIndex
    if (newCellIndex + @options['rows']) < @cells.length
      newCellIndex += @options['rows']
    else
      newCellIndex = 0 if @options['loop']

    unless newCellIndex is @currentCellIndex
      this.goTo(newCellIndex)
      this.startSlideshow(@options['autoNextInterval'])

  startSlideshow: (delay) ->
    $('#slideshow_label').text('stop slideshow')
    @slideshowTimer = setTimeout((=> this.autoNext()), delay)

  stopSlideshow: ->
    $('#slideshow_label').text('start slideshow')
    this.killTimer('slideshowTimer')

  killTimer: (timerName) ->
    if this[timerName]
      clearTimeout(this[timerName])
      this[timerName] = null
