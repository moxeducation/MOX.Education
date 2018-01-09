#= require user
#= require image
#= require tag
#= require tile
#= require product
#= require helpers
#
#= require images-cache

class AppViewModel
  grids: {}
  searchQuery: ko.observable ''

  currentUser: ko.observable new User

  allProducts: ko.observableArray()
  visibleProducts: ko.observableArray()
  activeProduct: ko.observable()

  visibleTiles: ko.observableArray()
  activeTile: ko.observable()

  tags: ko.observableArray()

  showGroupsList: ko.observable(false)
  ownGroups: ko.observableArray()
  groups: ko.observableArray()
  otherGroups: ko.observableArray()
  invitations: ko.observableArray()
  applications: ko.observableArray()
  groupInvitations: ko.observableArray()
  groupApplications: ko.observableArray()
  selectedGroup: ko.observable()
  groupProducts: ko.observableArray()
  groupsProducts: ko.observableArray()
  groupUsers: ko.observableArray()

  history: ko.observableArray()
  
  publicMode: true

  imagesCache: new ImagesCache() unless (new MobileDetect(navigator.userAgent)).mobile()

  constructor: ->

    showDialog = (dialog) ->
      dialog = $("#dialog-wrapper > .dialog").hide().filter("##{dialog}")
      dialog.show()
      $('input[type=email]').val($('.dialog#login input[type=email]').val()) if dialog.is('#restore')
      $('input[type=password]', dialog).val('')
      $('#dialog-wrapper').fadeIn()

    $(document).on 'click', 'a[data-dialog], input[data-dialog]', ->
      dialog = $(this).data 'dialog'
      showDialog dialog
      false
    $('#dialog-wrapper').on 'click', (event) ->
      if event.target == this
        $(this).fadeOut ->
          $('#new-tag input.file').each -> $(this).replaceWith $(this).clone()
          $('#new-tag input.name').val('')
          $('#new-tag div.image').addClass('empty').css
            backgroundImage: ''
        false

    $('#menu a.tags').on 'click', =>
      @renderAllTags()

    if window.initialDialog
      showDialog window.initialDialog

    @updateHistoryBoxSize = =>
      return if @publicMode
      $('#history').css
        maxWidth: 0
        overflow: 'hidden'

      width = $('#logo').offset().left - $('#history').offset().left - 100

      $('#history').css
        maxWidth: width
        overflow: 'visible'

      x = 0
      $('#history > a').hide().each ->
        x += $(this).outerWidth(true)
        if x < width
          $(this).show()
    $(window).on 'resize', @updateHistoryBoxSize

    uhbTimer1 = null
    uhbTimer2 = null
    updateHistoryBoxSizeByTimer = (timeout) =>
      clearTimeout uhbTimer1
      clearInterval uhbTimer2
      uhbTimer1 = setTimeout ->
        clearInterval uhbTimer2
      , timeout
      uhbTimer2 = setInterval @updateHistoryBoxSize, 10

    $('#new-tag input.image').on 'change', ->
      file = this.files[0]

      reader = new FileReader()
      reader.onload = ->
        generateThumbnail reader.result, 200, (thumbnails) ->
          $('#new-tag div.image').removeClass('empty').css
            backgroundImage: "url(#{thumbnails[200]})"
      reader.readAsDataURL(file)
      true
    $('#new-tag input.save').on 'click', =>
      name = $('#new-tag input.name').val().trim()
      imageFile = $('#new-tag input.image')[0].files[0]

      product = @activeProduct()
      if product && name != '' && imageFile
        tag = @findTag name
        if tag.persisted()
          product.tags.push tag.name()
          product.save()
        else
          tag.image imageFile
          tag.create()

      $('#dialog-wrapper').trigger 'click'

    @spinSaveButton = ->
      $('#save_button').find('i').removeClass('fa-floppy-o')
      $('#save_button').find('i').addClass('fa fa-spinner fa-spin fa-lg')

    @counter = 0
    $(document).on 'dragenter', '.large.tile.preview.editing', (event) =>
      if (@counter == 0)
        $('.drag-n-drop').show()
        $('.large.tile.preview.editing > *:not(.drag-n-drop)').hide()
      @counter++
      false
    $(document).on 'dragleave', '.drag-n-drop', (event) =>
      if (@counter <= 2)
        $('.drag-n-drop').hide()
        $('.large.tile.preview.editing > *:not(.drag-n-drop)').show()
        @counter = 0
      @counter--
      false
    $(document).on 'dragover', '.large.tile.preview.editing', (event) =>
      event.preventDefault()
    $(document).on 'drop', '.large.tile.preview.editing', (event) =>
      $('.drag-n-drop').hide()
      $('.large.tile.preview.editing > *:not(.drag-n-drop)').show()
      @counter = 0
      data = event.originalEvent.dataTransfer.getData("text/plain")
      if data.startsWith('http')
        @spinSaveButton()
        if data.startsWith(window.location.origin)
          slug = data.substr(window.location.origin.length + 1)
          product = _.find @allProducts(), (product) -> product?.slug() == slug
          product ||= _.find @groupsProducts(), (product) -> product?.slug() == slug
          @activeTile().linkedProductId product.id()
        else
          @activeTile().content data
        @activeTile().save()
        false

    self = @
    $('#search').on 'focus', ->
      $(this).addClass 'active'
      updateHistoryBoxSizeByTimer 200
    $('#search').on 'blur', ->
      if $(this).val().trim() == ''
        $(this).removeClass 'active'
      updateHistoryBoxSizeByTimer 200
    $('#search').on 'keydown keyup keypress change', =>
      @searchQuery $('#search').val()

    @searchQuery.subscribe =>
      if @searchQuery() == null
        $('#search').val('').blur()
        return

      if @activeProduct()
        tiles = _.filter(@activeProduct().tiles(), (tile) => tile.search(@searchQuery()))
        if @visibleTiles().length != tiles.length
          @visibleTiles tiles
          @updateAllTemplates()
          @refreshGrid()
      else
        products = _.filter(@allProducts(), (product) => product.search(@searchQuery()))
        if @visibleProducts().length != products.length
          @visibleProducts products
          @updateAllTemplates()
          @refreshGrid()

    $(window).on 'scroll', =>
      return unless @activeProduct()
      product = @activeProduct()

      viewport =
        left: document.body.scrollLeft
        top: document.body.scrollTop
      viewport.right = viewport.left + document.body.clientWidth
      viewport.bottom = viewport.top + document.body.clientHeight

      $('#product-tiles > .tile').each ->
        position = $(this).offset()
        position.right = position.left + $(this).width()
        position.bottom = position.top + $(this).height()

        if position.top <= viewport.bottom && position.bottom >= viewport.top && position.left <= viewport.right && position.right >= viewport.left
          if $('.content-on-scroll', this).length > 0
            tileId = parseInt $(this).data('tile-id')
            tile = _.find(product.tiles(), (tile) -> tile.id() == tileId)

            if tile
              $('.content-on-scroll', this).replaceWith($('<div class="content" />').addClass(tile.tileType()).html(tile.contentFormatted()))

    @grids.productsListGrid = new TileGrid
      container: '#products-list'
      selector: '.medium.tile'
      tileSize: 200
      margin: 10
      draggable: false
      dummy: '<div class="medium dummy tile" />'
      onDragEnd: @updateProductsOrder

    @grids.productPreviewTilesetGrid = new TileGrid
      container: '#product-tiles .preview-tileset'
      selector: '.small.tile'
      tileSize: 120
      margin: 5
      dummy: '<div class="small dummy tile" />'
      draggable: false
      fixContainerHeight: false
      onDragEnd: @updateActiveProductTilesOrder

    @grids.productTilesGrid = new TileGrid
      container: '#product-tiles'
      selector: '.large.tile'
      tileSize: -> Math.max($(window).width() / 3, 400)
      margin: 10
      nestedGrids: [@grids.productPreviewTilesetGrid]

    @constructGroupsTileGrid('ownGroupsGrid', '#groups .own-groups .own-groups-list')
    @constructGroupsTileGrid('memberGroupsGrid', '#groups .member-groups .member-groups-list')
    @constructGroupsTileGrid('otherGroupsGrid', '#groups .other-groups .other-groups-list')
    @constructGroupsTileGrid('applicationsGrid', '#groups .applications .applications-list')
    @constructGroupsTileGrid('invitationsGrid', '#groups .invitations .invitations-list')

    @allProducts.subscribe =>
      return unless @imagesCache

      _.each @allProducts(), (product) =>
        _.each product.tiles(), (tile) =>
          @imagesCache.push tile.file().original(), -4 if tile.tileType() == 'image'
          @imagesCache.push tile.file().medium(), -3
          @imagesCache.push tile.file().large(), -2
          @imagesCache.push tile.file().small(), -1

    # just because
    setTimeout =>
      @currentUser new User(preloadedData.currentUser)
      if @currentUser().persisted()
        @publicMode = false
      @allProducts _.map(preloadedData.products, (product) -> new Product(product)).sort(sortByOrder)
      @tags _.map(preloadedData.tags, (tag) -> new Tag(tag))
      @visibleProducts @allProducts()
      @loading false
      @refreshGrid()

      historyIds = localStorage?.getItem 'products-history'
      if historyIds
        @history _.map(historyIds.split(','), (id) => @getProductById parseInt(id))
        @updateHistory null

      if location.pathname != '/'
        slug = location.pathname.substring 1
        if slug.split('/')[0] == 'tag'
          tagName = slug.substring('tag/'.length)
          @showProductsByTagName tagName
        else
          if slug.split('/')[0] == 'public_products'
            slug = slug.substring('public_products/'.length)
            @publicMode = true
          product = _.find @allProducts(), (product) -> product?.slug() == slug
          @selectProduct product if product

      if @publicMode
        @grids.productTilesGrid.singleRow = true
        computeTileSize = => #TODO: Get rid of this and markup using flexbox
          scrollbarSize = 15
          wrapperPaddings = $("#wrapper").outerHeight(true) - $("#wrapper").height()
          height = window.innerHeight - $("#header").outerHeight() - wrapperPaddings - scrollbarSize
          width = $("#wrapper").width() / 2 - @grids.productTilesGrid.margin
          Math.min(height, width)
        @grids.productTilesGrid.tileSize = computeTileSize
        @grids.productTilesGrid.update()
        COLUMNS = 6
        computePreviewTileSize = =>
          tsize = computeTileSize()
          margin = @grids.productPreviewTilesetGrid.margin
          Math.floor((tsize - ((COLUMNS + 1) * margin)) / COLUMNS)
        @grids.productPreviewTilesetGrid.tileSize = computePreviewTileSize
        @grids.productPreviewTilesetGrid.update()
      else
        @loadGroups()
    , 1

    History.Adapter.bind window, 'statechange', =>
      state = History.getState()
      if state.productId
        productId = state.data?.productId
        product = _.find @allProducts(), (product) -> product?.id() == productId
        if product
          @selectProduct product
        else
          @deselectProduct()
      else if state.tagName
        @showProductsByTagName state.tagName

    $(document).on 'click', 'a.exit-fullscreen', ->
      helpers.exitFullscreen()

    $(document).on 'keydown', (event) =>
      if @activeProduct?()?.tiles?() && @activeTile?()
        if helpers.fullscreenElement()
          index = _.indexOf _.map(@activeProduct().tiles(), (x) -> x?.id()), @activeTile()?.id()
          if event.keyCode == 37 && index > 0 # arrow left
            @activeTile @activeProduct().tiles()[index - 1]
            @updateAllTemplates()
            @refreshGrid()
            false
          else if (event.keyCode == 39 || event.keyCode == 32) && index < @activeProduct().tiles().length - 1 # arrow right or space
            @activeTile @activeProduct().tiles()[index + 1]
            @updateAllTemplates()
            @refreshGrid()
            false

    @updateAllTemplates()

  constructGroupsTileGrid: (name, container) ->
    @grids[name] = new TileGrid
      container: container
      selector: '.medium.tile'
      tileSize: 120
      margin: 10
      draggable: false
      dummy: '<div class="medium dummy tile" />'
      
  groupBackgroundImage: (url)->
    {"background-image": url ? "url('#{url}')" : ''}

  activeDialog: ko.observable()
  showDialog: (el, event) ->
    @activeDialog event.target.className
  hideDialog: (el, event) ->
    if $(event.target).is('#dialog-wrapper')
      @activeDialog null
    else
      true

  loading: (value) ->
    if value
      $(document.body).addClass 'loading'
    else
      $(document.body).removeClass 'loading'
    @updateAllTemplates()
    @refreshGrid()

  refreshGrid: =>
    @grids.productsListGrid.draggable = @currentUser?()?.isAdmin()
    @grids.productPreviewTilesetGrid.draggable = @activeProduct?()?.editable?()

    if @activeProduct?()
      @grids.productPreviewTilesetGrid.update()
      @grids.productTilesGrid.update()
    else
      @grids.productsListGrid.update() unless @activeProduct?()

    if helpers.fullscreenElement()
      $('.preview-tileset').perfectScrollbar
        useBothWheelAxes: true
        suppressScrollY: true
    else
      $('.preview-tileset').perfectScrollbar
        useBothWheelAxes: false
        suppressScrollY: false

  updateMemberGroupsGrid: =>
    @grids.memberGroupsGrid.update()

  updateOwnGroupsGrid: =>
    @grids.ownGroupsGrid.update()

  updateOtherGroupsGrid: =>
    @grids.otherGroupsGrid.update()

  updateApplicationsGrid: =>
    @grids.applicationsGrid.update()

  updateInvitationsGrid: =>
    @grids.invitationsGrid.update()

  loadUser: =>
    $.getJSON '/users/current.json', (data) =>
      @currentUser new User(data)

  loadProducts: =>
    $.getJSON '/products.json', (data) =>
      @allProducts _.map(data.products, (product) -> new Product(product)).sort(sortByOrder)
      @visibleProducts @allProducts()
      @loading false
      @refreshGrid()

  loadGroups: =>
    $.get '/groups', (data) =>
      @groups data.groups
      @ownGroups data.own_groups
      @otherGroups data.other_groups
      @invitations data.invitations
      @applications data.applications

  getProductById: (product_id) =>
    _.find @allProducts(), (product) -> product.id() == product_id

  updateProductsOrder: =>
    tileset = $('#products-list')
    els = tileset.children '.medium.tile[data-id]'

    self = @
    data = {}
    els.each (index) ->
      id = parseInt $(this).data('id')
      order = -(els.length - index)
      if self.getProductById(id).order() != order
        data[id] = order

    if _.size(data) == 0
      # little hack to force .add.tile to be always at end of list
      tileset.children('.add.tile').detach().appendTo tileset
      @updateAllTemplates()
      @refreshGrid()
      return

    $.ajax
      url: '/products/order'
      type: 'post'
      data:
        products_order: data
      success: (data) =>
        @allProducts _.map(data.products, (product) -> new Product(product)).sort(sortByOrder)
        @visibleProducts @allProducts()

        @updateAllTemplates()
        @refreshGrid()

  updateActiveProductTilesOrder: =>
    tileset = $('#product-tiles .preview-tileset')
    els = tileset.children('.small.tile[data-id]')
    product = @activeProduct()

    data = {}
    els.each (index) ->
      id = parseInt $(this).data('id')
      order = -(els.length - index)
      if product.getTileById(id)?.order() != order
        data[id] = order

    if _.size(data) == 0
      # little hack to force .add.tile to be always at end of list
      tileset.children('.add.tile').detach().appendTo tileset
      @refreshGrid()
      return

    $.ajax
      url: @activeProduct().url() + '/tiles-order'
      type: 'post'
      data:
        tiles_order: data
      success: (data) =>
        # little hack to force knockout.js regenerate .preview-tileset
        product = @activeProduct()
        @activeProduct null
        product.update data
        @activeProduct product
        @visibleTiles @activeProduct().tiles()

        @updateAllTemplates()
        @refreshGrid()

  updateMetaTags: =>
    if @activeProduct() && @activeProduct().persisted()
      tile = @activeProduct()?.tiles()[0]
      description = (tile.content() || '').replace(/<\/?[^>]+>/gi, '')
      description = tile.title() if description == ''

      image = tile.file()?.medium()
      image = $('meta[name="root_url"]').attr('content') + image

      $('meta[itemprop="name"], meta[name="twitter:title"], meta[name="og:title"]').attr('content', tile.title())
      $('meta[itemprop="description"], meta[name="twitter:description"], meta[name="og:description"]').attr('content', )
      $('meta[itemprop="image"], meta[name="twitter:image"], meta[name="og:image"]').attr('content', image)
      $('meta[name="og:type"]').attr('content', 'article')
    else
      $('meta[itemprop="name"], meta[name="twitter:title"], meta[name="og:title"]').attr('content', 'Madeofx')
      $('meta[itemprop="description"], meta[name="twitter:description"], meta[name="og:description"]').attr('content', 'What everything is made of')
      $('meta[itemprop="image"], meta[name="twitter:image"], meta[name="og:image"]').attr('content', $('meta[name="msapplication-TileImage"]').attr('href'))
      $('meta[name="og:type"]').attr('content', 'website')

  updateHistory: (product) =>
    @history _.filter(@history(), (p) -> p != null)

    if product
      @history _.filter(@history(), (p) -> p && p.id() != product.id())
      @history _.last @history(), 14
      @history.push product

      localStorage?.setItem 'products-history', _.map(@history(), (p) -> p.id()).join(',')

    container = $('#history')
    container.empty()
    _.each @history(), (product) =>
      return unless product && product.hasTiles()

      el = $('<a />')
      el.attr 'href', product.slugUrl()
      el.css backgroundImage: product.tiles()[0].file()?.cssSmall()

      $('<span class="tooltip" />').text(product.title()).appendTo el

      el.on 'click', =>
        @selectProduct product
        false

      el.prependTo container

    unless @publicMode
      @updateHistoryBoxSize()

  showGroups: () ->
    @loadGroups()
    @activeProduct null
    @activeTile null
    @visibleProducts null
    @visibleTiles null
    @searchQuery null
    @showGroupsList true
    @selectedGroup null
    @updateAllTemplates()
    @refreshGrid()
    @updateMetaTags()
    @updateOwnGroupsGrid()
    addToHistory('MadeOFX', '/groups')
    window.scrollTo 0, 0
    false

  openGroup: (group) =>
    History.pushState {groupName: group.name}, "#{group.name} - MadeOFX", "/groups/#{group.id}"
    @showGroupsList false
    $.get '/groups/' + group.id, (data) =>
      @selectedGroup data
      @groupUsers data.users
      @groupApplications data.applications
      @groupInvitations data.invitations
      @visibleProducts(_.map(data.products, (p)-> new Product(p)).sort(sortByOrder))
      @groupProducts(@visibleProducts())
      @groupsProducts.push(p) for p in @visibleProducts()
      @updateAllTemplates()
      @refreshGrid()
    @selectedGroup group
    @activeProduct null
    @activeTile null
    @visibleProducts null
    @visibleTiles null
    @searchQuery null
    window.scrollTo 0, 0
    false

  reopenGroup: =>
    @openGroup(@selectedGroup())
    
  groupAdmin: =>
    @currentUser().id() == @selectedGroup()?.admin_id

  toggleCreateGroup: =>
    $("#groups .create-group").slideToggle("medium");

  toggleOtherGroupsMenu: =>
    $("#groups .other-groups").slideToggle("slow");
    @updateOtherGroupsGrid()
    $('html, body').animate({
      scrollTop: $("#groups .other-groups").offset().top + $('window').height()
    }, "slow");

  toggleManagementMenu: =>
    $("#group-management .management-section").slideToggle("slow");
    
  somethingWentWrongNoty: ->
    noty
      text: "We are sorry, but something went wrong."
      type: 'error'
      timeout: 10000

  successNoty: (message) ->
    noty
      text: message
      type: 'success'
      timeout: 10000

  userInvitationEmail: ko.observable()
  inviteUser: (formData) =>
    promise = $.post("/groups/#{@selectedGroup().id}/invitations", email: @userInvitationEmail())
    promise.done (data) =>
      @userInvitationEmail ''
      @groupInvitations.push(data)
      @successNoty "User <b>#{data.user.email}</b> was invited."
    promise.fail (data) =>
      noty
        text: "#{data.responseText}"
        type: 'error'
        timeout: 10000
    false

  bindFileUploadButton: =>
    $('#groups .create-group .create-group-form .create-group-file-button').click () ->
      $('#groups .create-group .create-group-form .create-group-file-input').trigger('click')

  createGroup: (formData) =>
    $(formData).ajaxSubmit
      url: '/groups'
      type: 'POST'
      success: (data) =>
        @ownGroups.push(data)
        $(formData).clearForm()
        @successNoty "Group <b>#{data.name}</b> <br> was succesfully created."
        @toggleCreateGroup()
      error: () =>
        @somethingWentWrongNoty()

  updateGroup: (formData) =>
    group = @selectedGroup()
    $(formData).ajaxSubmit
      url: "/groups/#{group.id}"
      type: 'PUT'
      success: (data) =>
        @selectedGroup()[p] = data[p] for p in data
        @selectedGroup.valueHasMutated()
        $(formData).find("input[type=file]").val('')
        document.title = data.name;
        @toggleManagementMenu()
        @successNoty "Group <b>#{data.name}</b> <br> was succesfully updated."
      error: () =>
        @somethingWentWrongNoty()

  deleteGroup: () =>
    return unless confirm('This will destroy all group data, are you sure?')
    group = @selectedGroup()
    $.ajax
      url: "/groups/#{group.id}"
      method: "DELETE"
      success: (data) =>
        @ownGroups.remove((g) -> g == group)
        @showGroups()
        @successNoty "Group <b>#{group.name}</b> was deleted."
      error: () =>
        @somethingWentWrongNoty()

  acceptInvitation: (invitation) =>
    promise = $.post("/groups/#{invitation.group_id}/invitations/#{invitation.id}/accept")
    promise.done (data) =>
      @invitations.remove((i) -> i == invitation)
      @groups.push(invitation.group)
      @updateInvitationsGrid()
      @successNoty "Invitation from group <b>#{invitation.group.name}</b> <br> was accepted."
    promise.fail (data) =>
      @somethingWentWrongNoty()

  declineInvitation: (invitation) =>
    promise = $.post("/groups/#{invitation.group_id}/invitations/#{invitation.id}/decline")
    promise.done (data) =>
      @invitations.remove((i) -> i == invitation)
      @successNoty "Invitation from group <b>#{invitation.group.name}</b> <br> was declined."
    promise.fail (data) =>
      @somethingWentWrongNoty()

  sendApplication: (group) =>
    promise = $.post("/groups/#{group.id}/applications")
    promise.done (data) =>
      @otherGroups.remove((g) -> g == group)
      @applications.push data
      @updateOtherGroupsGrid()
      @successNoty "Join request to group <b>#{group.name}</b> <br> was sent."
    promise.fail (data) =>
      @somethingWentWrongNoty()
    false

  acceptApplication: (application) =>
    promise = $.post("/groups/#{@selectedGroup().id}/applications/#{application.id}/accept")
    promise.done (data) =>
      @groupApplications.remove((a) -> a == application)
      @groupUsers.push(application.user)
      @successNoty "Request from user <b>#{application.user.email}</b> <br> was accepted."
    promise.fail (data) =>
      @somethingWentWrongNoty()

  declineApplication: (application) =>
    promise = $.post("/groups/#{@selectedGroup().id}/applications/#{application.id}/decline")
    promise.done (data) =>
      @groupApplications.remove((a) -> a == application)
      @successNoty "Request from user <b>#{application.user.email}</b> <br> was declined."
    promise.fail (data) =>
      @somethingWentWrongNoty()

  selectProduct: (product, event) =>
    return if event && event.button != 0

    @activeTile product?.tiles()[0]
    @activeTile()?.editing false
    @activeProduct product
    @visibleTiles product?.tiles()
    @searchQuery null
    @showGroupsList false
    @updateAllTemplates()
    @refreshGrid()
    @updateMetaTags()
    @updateHistory product
    unless @publicMode
      History.pushState {productId: product?.id()}, "#{product?.title()} - MadeOFX", product?.slugUrl()
      if window.ga
        window.ga 'set', { page: product?.slugUrl(), title: "#{product?.title()} - MadeOFX" }
        window.ga 'send', 'pageview'
      window.scrollTo 0, 0
    false

  deselectProduct: (scope, event) =>
    return if event && event.button != 0

    @activeProduct null
    @activeTile null
    @visibleProducts @allProducts()
    @visibleTiles null
    @searchQuery null
    @showGroupsList false
    @selectedGroup null
    @updateAllTemplates()
    @refreshGrid()
    @updateMetaTags()
    History.pushState {productId: null}, 'MadeOFX', '/'
    if window.ga
      window.ga 'set', { page: '/', title: "MadeOFX" }
      window.ga 'send', 'pageview'
    window.scrollTo 0, 0
    false

  showCompanyProducts: =>
    @activeProduct null
    @activeTile null
    @visibleProducts(_.filter @allProducts(), (product) => product.userId() == @currentUser?()?.id?() )
    @visibleTiles null
    @searchQuery null
    @showGroupsList false
    @selectedGroup null
    @updateAllTemplates()
    @refreshGrid()

  showUnapprovedProducts: =>
    @activeProduct null
    @activeTile null
    @visibleProducts(_.filter @allProducts(), (product) => !product.approved() )
    @visibleTiles null
    @searchQuery null
    @showGroupsList false
    @selectedGroup null
    @updateAllTemplates()
    @refreshGrid()

  showProductsByTagName: (tagName) =>
    History.pushState {tagName: tagName}, "#{tagName} - MadeOFX", "/tag/#{encodeURIComponent tagName}"

    @activeProduct null
    @activeTile null
    @visibleProducts(_.filter @allProducts(), (product) => product.hasTag(tagName) )
    @visibleTiles null
    @searchQuery null
    @selectedGroup null
    @updateAllTemplates()
    @refreshGrid()

  addProduct: =>
    product = new Product
      id: null
      title: ''
      group_id: @selectedGroup()?.id
      tiles: []
    product.tiles.push new Tile
      title: ''
      content: ''
    @activeProduct product
    @activeTile product.tiles()[0]
    @visibleTiles product?.tiles()
    @searchQuery null
    setTimeout =>
      @activeTile().editing true
    , 1
    @updateAllTemplates()
    @refreshGrid()

  selectTile: (tile) =>
    @activeTile().cancel()
    @activeTile tile
    @updateActivePreviewTile()
    @refreshGrid()
    if @publicMode
      window.scrollTo 0, 135
  deselectTile: =>
    @activeTile().cancel()
    @activeTile @activeProduct()?.tiles()[0]
    @visibleTiles @activeProduct()?.tiles()
    @searchQuery null
    @updateActivePreviewTile()
    @refreshGrid()
  addTile: =>
    @activeTile new Tile
      productId: @activeProduct().id()
      title: ''
      content: ''
    setTimeout =>
      @activeTile().editing true
    , 1
    @visibleTiles @activeProduct()?.tiles()
    @searchQuery null
    @updateActivePreviewTile()
    @refreshGrid()

  findTag: (name) =>
    tag = _.find @tags(), (tag) -> tag.name().toLowerCase() == name.toLowerCase()
    unless tag
      tag = new Tag
      tag.name name
    tag

  renderAllTags: =>
    container = $('.dialog#tags .tags')
    container.empty()

    _.each @tags(), (tag) =>
      el = $('<a class="tag" />')
      el.attr 'href', tag.slug()

      img = $('<span class="image" />')
      img.css backgroundImage: tag.image()?.cssMedium()
      img.appendTo el

      name = $('<span class="name" />')
      name.text tag.name()
      name.appendTo el

      el.on 'click', =>
        @showProductsByTagName tag.name()
        $('#dialog-wrapper').trigger 'click'
        false

      el.appendTo container

  renderProductTags: =>
    container = $('.dialog#tags .tags')
    container.empty()

    return unless @activeProduct()

    _.each @activeProduct().tags(), (tagName) =>
      if typeof(tagName) == 'string'
        tag = @findTag tagName
      else
        tag = tagName

      el = $('<a class="tag" />')
      el.attr 'href', tag.slug()

      img = $('<span class="image" />')
      img.css backgroundImage: tag.image()?.cssMedium()
      img.appendTo el

      name = $('<span class="name" />')
      name.text tag.name()
      name.appendTo el

      el.on 'click', =>
        @showProductsByTagName tag.name()
        $('#dialog-wrapper').trigger 'click'
        false

      el.appendTo container

  renderTagsSelect: =>
    container = $('.dialog#tags-select .tags')
    container.empty()

    return unless @activeProduct()

    _.each @tags(), (tag) =>
      el = $('<a class="tag" href="#" />')
      el.attr 'data-name', tag.name()

      if _.contains @activeProduct().tags(), tag.name()
        el.addClass 'selected'

      img = $('<span class="image" />')
      img.css backgroundImage: tag.image()?.cssMedium()
      img.appendTo el

      name = $('<span class="name" />')
      name.text tag.name()
      name.appendTo el

      el.on 'click', ->
        $(this).toggleClass 'selected'
        false

      el.appendTo container

    $('.dialog#tags-select input.save').off('click').on 'click', =>
      tags = []
      $('.tag.selected', container).each ->
        tags.push $(this).data('name')
      @activeProduct().tags tags
      @activeProduct().save()
      $('#dialog-wrapper').trigger 'click'
      false

  renderProductLargeTile: (product, tile, isPreview = false) =>
    el = $('<div class="large tile" />')
    el.attr 'data-tile-id', tile.id()
    el.addClass 'preview' if isPreview

    if isPreview && tile.editing()
      el.addClass 'editing'
      el.attr 'data-bind', "style: { backgroundColor: activeTile().color, backgroundImage: activeTile().file().cssLarge }, template: { name: 'product-tile-editing-template', data: activeTile }"
      return el

    if helpers.fullscreenElement()
      el.css
        'background-color': tile.color()
        'background-image': tile.file().cssOriginal()
    else
      el.css
        'background-color': tile.color()
        'background-image': tile.file().cssLarge()

    $('<div class="title" />').text(tile.title()).css(color: tile.titleColor()).appendTo(el)
    if tile.hasContentFormatted() && tile.tileType() != 'website'
      if isPreview || tile.isContentPreviewable()
        content = $('<div class="content" />').addClass(tile.tileType()).html(tile.contentFormatted())
        content.addClass('zoomed-out') if @publicMode
        content.appendTo(el)
      else
        $('<div class="content-on-scroll" />').appendTo(el)
    if tile.link()
      $('<a class="link" target="_blank" />').attr('href', tile.link()).appendTo(el)
    else if tile.lightboxUrl()
      $('<a class="link" target="_blank" />').attr('href', tile.lightboxUrl()).attr('data-title', tile.title()).attr('data-lightbox', tile.lightboxUrl()).appendTo(el)

    buttons = $('<div class="buttons" />')

    unless @publicMode
      $('<a class="fullscreen" href="#"><i class="fa fa-share" /><span class="tooltip">Share</span></a>').on('click', =>
        product.publish()
        iframe = "<iframe src='#{location.origin}/public_products/#{@activeProduct().slug()}' width='100%' height=600 />"
        window.prompt("Copy to clipboard: Ctrl+C, Enter", iframe);
        false
      ).appendTo(buttons)

    if isPreview && tile.editable()
      $('<a class="remove" href="#"><i class="fa fa-trash-o" /><span class="tooltip">Remove</span></a>').on('click', =>
        tile.remove()
        false
      ).appendTo(buttons)

      if !tile.isLinkedProduct()
        $('<a class="edit" href="#"><i class="fa fa-pencil" /><span class="tooltip">Edit</span></a>').on('click', =>
          tile.edit()
          false
        ).appendTo(buttons)

      if tile.isPrimaryTile() && product.persisted() && product.approvable()
        if @currentUser()?.isAdmin()
          if product.approved()
            $('<a class="disapprove" href="#"><i class="fa fa-thumbs-up" /><span class="tooltip">Disapprove product</span></a>').on('click', =>
              product.disapprove()
              false
            ).appendTo(buttons)
          else
            $('<a class="approve" href="#"><i class="fa fa-thumbs-o-up" /><span class="tooltip">Approve product</span></a>').on('click', =>
              product.approve()
              false
            ).appendTo(buttons)
        else
          if product.readyForApprove()
            $('<a class="disapprove" href="#"><i class="fa fa-thumbs-up" /><span class="tooltip">Product is ready for approve.</span></a>').on('click', =>
              false
            ).appendTo(buttons)
          else
            $('<a class="approve" href="#"><i class="fa fa-thumbs-o-up" /><span class="tooltip">Mark product as ready to approve.</span></a>').on('click', =>
              product.approve()
              false
            ).appendTo(buttons)

    if isPreview && (tile.editable() || product.tags()?.length > 0) && product.persisted() && @tags().length > 0
      btn = $('<a class="tags" href="#"><i class="fa fa-tags" /><span class="tooltip">Tags</span></a>')
      if tile.editable()
        btn.attr 'data-dialog', 'tags-select'
      else
        btn.attr 'data-dialog', 'tags'

      btn.on 'click', =>
        @renderProductTags()
        @renderTagsSelect()
        true

      btn.appendTo buttons

    if true # for scoping
      btn = $('<a class="fullscreen" href="#"><i class="fa fa-television" /><span class="tooltip">Presentation mode</span></a>')
      btn.on 'click', =>
        container = $('#product-tiles').get(0)
        helpers.requestFullscreen(container)
      unless @publicMode
        btn.appendTo buttons

    if buttons.children().length > 0
      buttons.appendTo(el)

    unless @publicMode
      $('<a class="exit-fullscreen" href="#"><i class="fa fa-times" /></a>').appendTo el

    el

  updateActivePreviewTile: =>
    product = @activeProduct()
    tile = @activeTile()
    return unless product && tile

    el = $('#product-tiles .large.preview.tile')
    el.replaceWith @renderProductLargeTile(product, tile, true)

    if typeof CKEDITOR != 'undefined'
      for instance in CKEDITOR.instances
        instance.removeAllListeners()
        CKEDITOR.remove instance

    ko.applyBindings viewModel, $('#product-tiles .large.preview.tile')[0]
    @refreshGrid()

  updateAllTemplates: =>
    if @activeProduct()
      $('#products-list').hide()
      container = $('#product-tiles').empty().show()

      product = @activeProduct()

      tile = @activeTile()
      container.append @renderProductLargeTile(product, tile, true)

      previewTileset = $('<div class="large tile preview-tileset tiles" />')
      _.each @visibleTiles(), (tile) =>
        el = $('<div class="small tile" />')
        el.css
          'background-color': tile.color()
          'background-image': tile.file().cssSmall()
        el.attr 'data-id', tile.id()
        el.on 'click', (event) =>
          @selectTile tile, event
          false

        tooltip = $('<div class="tooltip title" />').text(tile.title())
        tooltip.css('font-size', '1.75vmin') if @publicMode
        tooltip.appendTo(el)
        if tile.isContentPreviewable()
          el.addClass 'has-content'

        previewTileset.append el

      if product.editable()
        $('<div class="small dummy add tile" />').on('click', =>
          @addTile()
          false
        ).appendTo(previewTileset)

      previewTileset.appendTo(container)

      return if @publicMode

      _.each @visibleTiles(), (tile) =>
        return unless tile.persisted()
        container.append @renderProductLargeTile(product, tile, false)
    else
      $('#product-tiles').empty().hide()
      container = $('#products-list').show()

    @refreshGrid()

window.AppViewModel = AppViewModel
