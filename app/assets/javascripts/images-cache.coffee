class ImagesCache
  queue: []
  loading: []
  maxLoadingCount: 4
  cacheElement: '#cache'
  enabled: false

  constructor: ->
    $(window).load =>
      @enabled = true
      @update()

  push: (url, priority, callback) =>
    return false if typeof url != 'string' || url == ''
    if $('img[src="' + url + '"]').length > 0
      callback(url) if callback
      return true

    @queue.push
      url: url
      priority: priority
      callback: callback
    @update()
    true

  update: =>
    return false unless @enabled

    _.each @loading, (item) ->
      return unless item.image.complete
      item.callback(item.url) if item.callback

    @loading = _.filter @loading, (item) -> !item.image.complete

    if @loading.length < @maxLoadingCount && @queue.length > 0
      @queue = _.sortBy @queue, (item) -> item.priority
      while @loading.length < @maxLoadingCount && @queue.length > 0
        item = @queue.pop()

        image = new Image()
        image.onload = @update
        image.src = item.url
        image.dataset.priority = item.priority
        $(@cacheElement).append image

        item.image = image
        @loading.push item

      # to detect images loaded from cache
      # (some browsers don't fire onload event for these images)
      setTimeout @update, 100 if @loading.length > 0
      true
    else
      false

window.ImagesCache = ImagesCache
