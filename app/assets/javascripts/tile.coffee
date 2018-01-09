class Tile
  constructor: (data) ->
    @cachedData = ko.observable()

    unless data.color && data.file && data.file.large && data.file.large != ''
      data.color = generateColor()
      data.color = "#fff"

    _.each ['id', 'productId', 'editable', 'tileType', 'color', 'order', 'title', 'titleColor', 'content', 'contentFormatted', 'file', 'linkedProductId'], (field) =>
      @[field] = ko.observable()

    @editing              = ko.observable false
    @newFile              = ko.observable()

    @persisted            = => @id()
    @isPrimaryTile        = => !@id() || @product()?.tiles()[0]?.id() == @id()
    @isLinkedProduct      = => @linkedProductId()
    @hasContent           = => @content() && @content() != ''
    @hasContentFormatted  = => @contentFormatted() && @contentFormatted() != ''
    @hasFile              = => @file?()?.small() && @file?()?.small() != ''
    @link                 = =>
      if @tileType?() == 'website'
        return @content()
      if @linkedProductId()
        product = _.find(viewModel.allProducts(), (product) => product?.id() == @linkedProductId())
        return product.slugUrl() if product
      if @tileType?() == 'pdf'
        @file?()?.original?()
    @isContentPreviewable = => @hasContent() && !@tileType()?.startsWith('video')
    @image                = => @file()
    @product              = =>
      product = _.find(viewModel.allProducts(), (x) => x.id() == @productId())
      product ||= _.find(viewModel.groupsProducts(), (x) => x.id() == @productId())
      product
    @url                  = => "/products/#{@productId()}/tiles/#{@id() || ''}"
    @lightboxUrl          = => (@file?()?.original?() if @tileType?() == 'image')
    @search               = (query) =>
      query = query.trim().toLowerCase()
      found = @title()?.toLowerCase()?.indexOf(query)
      if found != null && found >= 0
        return true
      found = @content()?.toLowerCase()?.indexOf(query)
      if found != null && found >= 0
        return true
      return false

    @editing.subscribe ->
      viewModel.updateActivePreviewTile()

    @update data

  update: (data) =>
    @cachedData data

    _.each ['id', 'productId', 'editable', 'tileType', 'color', 'order', 'title', 'titleColor', 'content', 'contentFormatted', 'linkedProductId'], (field) =>
      @[field] data[field]
    @file new TileImage(data.file)

    @product()?.update data.product if data.product

    @newFile
      file: ko.observable()
      data: ko.observable()
      name: ko.observable()
      type: ko.observable()
    @newFile().data.subscribe (newValue) =>
      if newValue != null
        if newValue.startsWith 'data:image'
          @file().original null
          @file().small null
          @file().medium null
          @file().large null

          if (@newFile().file()?.size|0) >= 300 * 1024 * 1024
            @newFile().file null
            @newFile().data null
            @newFile().name null
            @newFile().type null

            noty
              text: "File too large."
              type: 'error'
              timeout: 5000

            return

          generateThumbnail newValue, [100, 200, 800], (thumbnails) =>
            @file().small thumbnails[100]
            @file().medium thumbnails[200]
            @file().large thumbnails[800]
        else
          @file().small null
          @file().medium null
          @file().large null
          @file().original null

        noty
          text: 'File added.'
          type: 'success'
          timeout: 3000

        fileType = @newFile().file?()?.type
        if fileType == 'application/pdf'
          @newFile().type 'pdf'
        else if fileType.startsWith 'image/'
          @newFile().type 'image'
        else if fileType.startsWith 'video/'
          @newFile().type 'video'
        else
          @newFile().type null
      else
        @file new TileImage @cachedData().file

  reload: =>
    @editing false

    $.ajax
      url: @url()
      type: 'get'
      success: (data) =>
        @update data

  edit: =>
    @editing true
    viewModel.refreshGrid()
  cancel: =>
    return unless @editing()

    if !@productId()
      viewModel.deselectProduct()
      return

    @editing false
    @update @cachedData()
    if @persisted()
      viewModel.refreshGrid()
    else
      viewModel.deselectTile()

  clearFile: =>
    @newFile().file 'delete'
    @newFile().data ''
    @newFile().name ''
    @newFile().type ''

  save: =>
    # @editing false

    unless @product()
      viewModel.activeProduct().save()
      return

    formData = new FormData()
    formData.append '_method', 'put' if @id() && @id() > 0

    _.each ['color', 'order', 'title', 'content'], (field) =>
      formData.append "tile[#{field}]", @[field]() if @[field]() != null
    formData.append "tile[title_color]", @titleColor() if @titleColor()
    formData.append "tile[linked_product_id]", @linkedProductId()

    if @newFile().file()
      if typeof @newFile().file() == 'object'
        formData.append 'tile[file]', @newFile().file()
      else if @newFile().file() == 'delete'
        formData.append 'tile[delete_file]', '1'

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
          @update data
          @product().tiles.push @

          viewModel.updateAllTemplates()
          # viewModel.refreshGrid()

          noty
            text: 'Tile saved.'
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

          noty
            text: 'Tile saved.'
            type: 'success'
            timeout: 3000
        complete: ->
          viewModel.updateAllTemplates()
          viewModel.loading false
          $(document.body).removeClass 'loading'

    # viewModel.updateAllTemplates()
    # viewModel.refreshGrid()

  remove: =>
    viewModel.deselectTile()
    return unless @id() && @id() > 0

    if @product().tiles().length <= 1
      @product().remove()
      return

    @product().tiles _.without(@product().tiles(), @)

    viewModel.updateAllTemplates()
    viewModel.refreshGrid()

    $.ajax
      url: @url()
      type: 'post'
      data:
        _method: 'delete'

window.Tile = Tile
