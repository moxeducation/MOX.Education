class Product
  constructor: (data) ->
    @cachedData = ko.observable()

    _.each ['id', 'slug', 'order', 'userId', 'approved', 'editable', 'approvable', 'readyForApprove', 'group_id', 'public'], (field) =>
      @[field] = ko.observable()

    @persisted   = ko.observable => @id()
    @editing     = ko.observable false

    @tiles       = ko.observableArray()
    @url         = => "/products/#{@id() || ''}"
    @hasTiles    = => @tiles().length > 0
    @title       = =>
      return '' if @tiles().length == 0
      @tiles()[0]?.title()
    @slugUrl     = => "/#{@slug()}"
    @search      = (query) =>
      found = @title()?.toLowerCase()?.indexOf(query.trim().toLowerCase())
      if found != null && found >= 0
        return true
      found = _.find @tiles, (tile) -> tile.search(query)
      return found != undefined
    @tags        = ko.observableArray()
    @hasTag      = (tagName) => _.contains(@tags(), tagName)

    @update data

  update: (data) =>
    @cachedData data

    _.each ['id', 'slug', 'order', 'userId', 'approved', 'editable', 'approvable', 'readyForApprove', 'tags', 'group_id'], (field) =>
      @[field] data[field]
    if data.tiles
      @tiles _.map(data.tiles, (tile) -> new Tile(tile)).sort(sortByOrder)

    if viewModel.activeProduct() == @
      History.replaceState {productId: @id()}, "#{@title()} - MadeOFX", @slugUrl()

  save: =>
    formData = new FormData()
    formData.append '_method', 'put' if @id() && @id() > 0

    _.each @tags(), (tagName) ->
      formData.append "product[tags][]", tagName
    formData.set "product[group_id]", @group_id() if @group_id()
    for index, tile of @tiles()
      formData.append "product[tiles_attributes][#{index}][id]", tile.id() if tile.id()
      formData.append "product[tiles_attributes][#{index}][title]", tile.title() || ''
      formData.append "product[tiles_attributes][#{index}][linked_product_id]", tile.linkedProductId() || ''
      formData.append "product[tiles_attributes][#{index}][content]", tile.content() || ''
      if tile.newFile()?.file()
        if tile.newFile().file() != 'delete'
          formData.append "product[tiles_attributes][#{index}][file]", tile.newFile().file()
        else
          formData.append "product[tiles_attributes][#{index}][delete_file]", '1'

    # viewModel.loading true
    $(document.body).addClass 'loading'
    if !@id()
      $.ajax
        url: @url()
        type: 'post'
        data: formData
        dataType: 'json'
        cache: false
        contentType: false
        processData: false
        success: (data) =>
          if !@group_id()
            viewModel.allProducts.push @
          else
            viewModel.groupProducts.push @
            viewModel.groupsProducts.push @

          @update data

          viewModel.selectProduct @
          viewModel.updateAllTemplates()
          viewModel.refreshGrid()

          noty
            text: 'Product saved.'
            type: 'success'
            timeout: 3000
        complete:
          # viewModel.loading false
          $(document.body).removeClass 'loading'
    else if @id() > 0
      $.ajax
        url: @url()
        type: 'post'
        data: formData
        dataType: 'json'
        cache: false
        contentType: false
        processData: false
        success: (data) =>
          @update data

          viewModel.updateAllTemplates()
          viewModel.refreshGrid()

          noty
            text: 'Product saved.'
            type: 'success'
            timeout: 3000
        complete:
          # viewModel.loading false
          $(document.body).removeClass 'loading'

  remove: =>
    unless @id()
      viewModel.deselectProduct()
      return

    return unless confirm 'Are you sure want to delete this product?'

    viewModel.allProducts _.without(viewModel.allProducts(), @)
    viewModel.groupProducts _.without(viewModel.groupProducts(), @)
    viewModel.groupsProducts _.without(viewModel.groupsProducts(), @)
    viewModel.deselectProduct()

    $.ajax
      url: @url()
      type: 'post'
      data:
        _method: 'delete'

  approve: =>
    return unless @persisted()

    @approved true
    $.ajax
      url: "#{@url()}/approve"
      type: 'post'
      dataType: 'json'
      success: (data) =>
        @update data
        viewModel.updateAllTemplates()
        viewModel.refreshGrid()

  publish: =>
    return if @public()

    $.ajax
      url: "#{@url()}/publishes"
      type: 'post'
      dataType: 'json'
      success: (data) =>
        @update data

  disapprove: =>
    return unless @persisted()

    @approved true
    $.ajax
      url: "#{@url()}/disapprove"
      type: 'post'
      dataType: 'json'
      success: (data) =>
        @update data
        viewModel.updateAllTemplates()
        viewModel.refreshGrid()

  getTileById: (tile_id) =>
    _.find @tiles(), (tile) -> tile.id() == tile_id

window.Product = Product
