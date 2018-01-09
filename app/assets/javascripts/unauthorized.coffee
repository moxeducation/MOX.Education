#= require jquery
#= require jquery_ujs
#= require noty/jquery.noty
#= require noty/layouts/topRight
#= require noty/themes/default
#= require underscore
#= require images-cache

imagesCache = new ImagesCache()
imagesCache.maxLoadingCount = 1

updateGrid = ->
  grid = $('#grid')
  tileSize = $('.tile:first', grid).outerWidth(true)
  tileMargin = tileSize - $('.tile:first', grid).outerWidth(false)

  cols = Math.ceil($(window).width() / tileSize)
  rows = Math.ceil($(window).height() / tileSize)
  count = cols * rows

  grid.css
    marginLeft: ($(window).width() - (cols * tileSize)) / 2
    marginTop: ($(window).height() - (rows * tileSize)) / 2

  $('.tile:not(.special)', grid).remove()

  dialogPosition =
    col: Math.floor(cols * 1 / 3)
    row: Math.floor(rows * 1 / 3)
    width: (Math.floor(cols * 1 / 3) + 1) * tileSize - tileMargin
    height: (Math.ceil(rows * 1 / 2)) * tileSize - tileMargin

  dialogPosition.left = dialogPosition.col * tileSize
  dialogPosition.top = dialogPosition.row * tileSize

  for i in [0..count]
    col = i % cols
    row = Math.floor(i / cols)

    tile = null
    if col == Math.floor(cols * 2 / 3) && row == Math.floor(rows * 1 / 3)
      tile = $('#login.tile', grid)
    else if col == Math.floor(cols * 1 / 2) && row == Math.floor(rows * 2 / 3)
      tile = $('#signup.tile', grid)
    else if col == Math.floor(cols * 1 / 3) && row == Math.floor(rows * 1 / 2)
      tile = $('#about.tile', grid)
    else
      tile = $('<div class="tile" />')
      imageUrl = window.preloadedData.tileImages[i % window.preloadedData.tileImages.length]
      tile.attr('data-image', imageUrl)
      tile.appendTo grid

      imagesCache.push imageUrl, Math.random(), (imageUrl) ->
        tile = $("#grid .tile[data-image=\"#{imageUrl}\"]")
        image = $('<div class="image" />')
        image.css
          backgroundImage: "url(#{imageUrl})"
          top: Math.random() * 100 + '%'
          left: Math.random() * 100 + '%'
        image.appendTo tile

        setTimeout ->
          image.css
            left: 0
            top: 0
            width: '100%'
            height: '100%'
        , 10

    tile.data
      col: col
      row: row

    tile.css
      left: col * tileSize
      top: row * tileSize

  setTimeout ->
    $('.tile > .image', grid).css
      left: 0
      top: 0
      width: '100%'
      height: '100%'
  , 1

  hideDialog = ->
    $('.tile.special.active', grid).each ->
      $(this).removeClass 'active'

      col = parseInt($(this).data('col'))
      row = parseInt($(this).data('row'))

      $(this).removeAttr('style')

      if $(this).hasClass('hidden')
        $(this).css
          left: dialogPosition.left
          top: dialogPosition.top
          width: 0
          height: 0
      else
        $(this).css
          left: col * tileSize
          top: row * tileSize

      this.scrollTop = 0
      this.scrollLeft = 0

  showDialog = (tile) ->
    hideDialog()

    $(tile).addClass 'active'
    $(tile).css
      left: dialogPosition.left
      top: dialogPosition.top
      width: dialogPosition.width
      height: dialogPosition.height

  $('.tile.special.active', grid).each -> showDialog(this)

  $(grid).off('click').on 'click', (event) ->
    if $(event.target).is('.image, .tile:not(.special), #grid')
      hideDialog()
      false

  $('.tile.special', grid).off('click').on 'click', ->
    return if $(this).hasClass('active')
    showDialog(this)
    false

  $('a[data-dialog]').off('click').on 'click', ->
    showDialog($("##{$(this).attr('data-dialog')}"))
    false

  if window.initialDialog
    showDialog($("##{window.initialDialog}"))
    window.initialDialog = null

unless String.prototype.startsWith
  String.prototype.startsWith = (prefix) -> @.indexOf(prefix) == 0

$ ->
  $(window).on 'resize', updateGrid
  updateGrid()

  $('#login form').on 'ajax:success', (e, data) ->
    location.reload()
  $('#login form').on 'ajax:error', (e, xhr, status, error) ->
    $('.error', this).remove()

    data = xhr.responseJSON
    if data?.errors
      first = false
      for field, error of data.errors
        first = field unless first
        $('<span class="error" />').text(error[0]).insertAfter $('#login #user_' + field)
      $('#login #user_' + first).focus()
    else
      $('<span class="error" />').text('Invalid email or password').insertAfter $('#login #user_password')
      $('#login #user_password').focus()

    showNextError = false

  $('#signup form').on 'ajax:success', (e, data) ->
    location.reload()
  $('#signup form').on 'ajax:error', (e, xhr, status, error) ->
    $('#signup .error').remove()
    data = xhr.responseJSON
    if data?.errors
      first = false
      for field, error of data.errors
        first = field unless first
        $('<span class="error" />').text(error[0]).insertAfter $('#signup #user_' + field)
      $('#signup #user_' + first).focus()

    showNextError = false

  $('#restore form').on 'ajax:success', (e, data) ->
    $('#dialog-wrapper').fadeOut()
    noty
      text: "Instructions were sent to your email."
      type: 'success'
      timeout: 3000
  $('#restore form').on 'ajax:error', (e, xhr, status, error) ->
    noty
      text: "We are sorry, but something went wrong.<br>Please refresh page and try again."
      type: 'error'
      timeout: 10000

    showNextError = false

  $('#change-password form').on 'ajax:success', (e, data) ->
    $('#dialog-wrapper').fadeOut()
    noty
      text: "Password was successfully changed.<br />Now you can log in."
      type: 'success'
      timeout: 3000
    location.reload()
  $('#change-password form').on 'ajax:error', (e, xhr, status, error) ->
    $('#change-password .error').remove()
    data = xhr.responseJSON
    if data?.errors
      first = false
      for field, error of data.errors
        first = field unless first
        $('<span class="error" />').text(error[0]).insertAfter $('#change-password #user_' + field)
      $('#change-password #user_' + first).focus()

    showNextError = false

  $.noty.defaults.layout = 'topRight'
  $(document).on 'ajaxError', ->
    unless showNextError
      showNextError = true
      return

    noty
      text: "We are sorry, but something went wrong.<br>Please refresh page and try again."
      type: 'error'
      timeout: 10000

