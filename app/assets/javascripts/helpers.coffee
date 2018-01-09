root = exports ? this
root.helpers =
  addToHistory: (title, path) ->
    History.pushState {productId: null}, title, path
    if window.ga
      window.ga 'set', {page: path, title: title}
      window.ga 'send', 'pageview'

  fullscreenElement: () ->
    document.fullscreenElement || document.webkitFullscreenElement || document.mozFullscreenElement || document.msFullscreenElement
    
  requestFullscreen: (element) ->
    if element.requestFullscreen
      element.requestFullscreen()
    else if element.webkitRequestFullscreen
      element.webkitRequestFullscreen()
    else if element.mozRequestFullScreen
      element.mozRequestFullScreen()
    else if element.msRequestFullscreen
      element.msRequestFullscreen()

  exitFullscreen: () ->
    if document.cancelFullScreen
      document.cancelFullScreen()
    else if document.webkitCancelFullScreen
      document.webkitCancelFullScreen()
    else if document.mozCancelFullScreen
      document.mozCancelFullScreen()
    else if document.msCancelFullScreen
      document.msCancelFullScreen()
    false
