#= require mutationobserver.min

class TileGrid
  container: null
  selector: null
  tileSize: 200
  margin: 5
  dummy: null
  draggable: false
  transition: '0.2s left, 0.2s top, 0.2s width, 0.2s height'
  preferCSSSize: false
  onDragEnd: null
  nestedGrids: []
  fixContainerHeight: true
  singleRow: false

  hole: null
  dragged: null

  constructor: (options) ->
    _.each options, (value, key) =>
      @[key] = value

    @resetTileOrders()

    $(window).on 'resize', @update
    #observer = new MutationObserver @update
    #observer.observe $(@container).get(0),
    #  attributes: false
    #  childList: true
    #  characterData: false

    $(document).on 'mousedown', @container, (event) =>
      return unless @draggable && event.button == 0

      elements = @originalElements()
      element = $(event.target)
      while element.length > 0 && elements.filter(element).length == 0
        element = $(element).parent()
      return if element.length == 0 || @isDummy(element)

      elementX = parseFloat $(element).css('left')
      elementY = parseFloat $(element).css('top')
      startX = event.clientX
      startY = event.clientY

      mouseMove = (event) =>
        @dragged = element if !@dragged && event.clientX != startX && event.clientY != startY

        left = elementX - startX + event.clientX
        top = elementY - startY + event.clientY

        @update true

        element.css
          left: left
          top: top
          transition: 'none'
          zIndex: 100

        false

      mouseMove event
      $(document).on 'mousemove', mouseMove

      $(document).one 'mouseup', (event) =>
        if @dragged
          element.css
            zIndex: 'auto'
          @dragged = null

          @reorderTiles()
          @update()
          @onDragEnd?()
        else
          $(event.target).trigger 'click'

        $(document).off 'mousemove', mouseMove
        false
      false


  elements: => $(@container).children @selector
  originalElements: => @elements().filter ':not([data-dummy])'
  dummyElements: => @elements().filter '[data-dummy]'

  isDummy: (element) -> $(element).data 'dummy'

  resetTileOrders: =>
    originalElements = @originalElements()

    originalElements.each (index) ->
      $(this).attr 'data-tile-order', index
    @dummyElements().each (index) ->
      $(this).attr 'data-tile-order', originalElements.length + index

  updateTileOrders: (tileSize, columns) =>
    @resetTileOrders()

    if @dragged
      dragged = @dragged
      container = $(dragged).parent()[0]

      position = $(dragged).position()
      position.left += container.scrollLeft
      position.top += container.scrollTop
      column = Math.floor position.left / (tileSize + @margin)
      row = Math.floor position.top / (tileSize + @margin)

      draggedOrder = row * columns + column
      originalDraggedOrder = parseInt $(@dragged).attr('data-tile-order')

      $(dragged).attr 'data-tile-order', draggedOrder

      @elements().each ->
        return if $(this).is(dragged)

        order = parseInt $(this).attr('data-tile-order')
        order -= 1 if order >= originalDraggedOrder
        order += 1 if order >= draggedOrder
        $(this).attr 'data-tile-order', order

  reorderTiles: =>
    elements = @elements().detach()
    elements = _.sortBy elements, (element) -> parseInt($(element).attr('data-tile-order'))
    $(elements).appendTo @container

  updateTile: (element, tileSize, columns) =>
    return if @dragged && $(element).is(@dragged)

    order = parseInt $(element).attr 'data-tile-order'

    if @dragged
      draggedOrder = parseInt($(@dragged).attr 'data-tile-order')

    row = Math.floor order / columns
    column = order % columns

    $(element).css
      position: 'absolute'
      top: row * (tileSize + @margin)
      left: column * (tileSize + @margin)
      width: tileSize
      height: tileSize
      transition: @transition

  update: (refreshOrders, containerWidth, containerHeight) =>
    containerWidth = parseFloat $(@container).css('width') if containerWidth == undefined
    containerWidth = $(@container).width() if containerWidth == NaN
    containerHeight = parseFloat $(@container).css('height') if containerHeight == undefined
    containerHeight = $(@container).height() if containerHeight == NaN

    elements = @elements()
    originalElements = @originalElements()
    dummyElements = @dummyElements()

    tileSize = @tileSize?() ? @tileSize
    columns = Math.floor (containerWidth + @margin) / (tileSize + @margin)
    if @singleRow
      columns = elements.length
      rows = 1
    else
      tileSize = (containerWidth - @margin * (columns - 1)) / columns

    tilesCount = elements.length
    dummyTilesCount = 0

    if @dummy
      rows = Math.floor (containerHeight + @margin) / (tileSize + @margin)
      rows = Math.max rows, Math.ceil(originalElements.length / columns)

      tilesCount = columns * rows
      dummyTilesCount = tilesCount - originalElements.length

    if tilesCount != 0 || elements.length != 0
      if dummyTilesCount < dummyElements.length
        dummyElements.slice(dummyTilesCount).remove()
        elements = @elements()
      else if dummyTilesCount > dummyElements.length
        for i in [1..(dummyTilesCount - dummyElements.length)]
          $(@container).append $(@dummy).clone().attr('data-dummy', true)
        elements = @elements()

      @updateTileOrders tileSize, columns if refreshOrders == undefined || refreshOrders

      elementIndex = 0
      tileIndex = 0
      for element in elements
        @updateTile element, tileSize, columns

    rows = Math.ceil elements.length / columns unless rows
    $(@container).height rows * (tileSize + @margin) - @margin if @fixContainerHeight

    _.each @nestedGrids, (grid) -> grid.update(refreshOrders, tileSize, tileSize)

window.TileGrid = TileGrid
