isArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

window.generateThumbnail = (source, sizes, callback) ->
  canvas = document.createElement 'canvas'

  sizes = [sizes] unless isArray sizes

  unless canvas.getContext
    result = {}
    for size in sizes
      result[size] = source
    callback result
    return

  image = new Image
  image.src = source
  image.onload = ->
    context = canvas.getContext '2d'
    result = {}
    for size in sizes
      if image.width > image.height
        canvas.width = size * image.width / image.height
        canvas.height = size
      else
        canvas.height = size * image.height / image.width
        canvas.width = size
      context.drawImage image, 0, 0, canvas.width, canvas.height
      result[size] = canvas.toDataURL()
    callback result

class TileImage
  constructor: (data) ->
    _.each ['original', 'small', 'medium', 'large'], (field) =>
      @[field] = ko.observable data?[field]

    @cssOriginal = ko.computed =>
      if @original()
        "url(#{@original()})"
      else
        ''

    @cssSmall    = ko.computed =>
      if @small()
        "url(#{@small()})"
      else
        @cssOriginal()

    @cssMedium   = ko.computed =>
      if @medium()
        "url(#{@medium()})"
      else
        @cssOriginal()

    @cssLarge    = ko.computed => 
      if @large()
        "url(#{@large()})"
      else
        @cssOriginal()

window.TileImage = TileImage
