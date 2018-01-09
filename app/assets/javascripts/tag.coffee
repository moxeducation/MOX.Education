class Tag
  constructor: (data) ->
    @cachedData = ko.observable()

    _.each ['name', 'image', 'persisted'], (field) =>
      @[field] = ko.observable()

    @slug = => "/tag/#{encodeURIComponent @name()}"

    @persisted false
    @update data if data

  update: (data) =>
    @cachedData data

    _.each ['name'], (field) =>
      @[field] data[field]
    @image new TileImage(data.image)
    @persisted true

  create: =>
    return if @persisted()

    formData = new FormData()
    formData.append '_method', 'post'
    formData.append "tag[name]", @name()
    formData.append "tag[image]", @image()

    $.ajax
      url: '/tags/'
      type: 'post'
      data: formData
      dataType: 'json'
      cache: false
      contentType: false
      processData: false
      success: (data) =>
        @update data

        viewModel.tags.push @
        viewModel.updateAllTemplates()
        viewModel.activeProduct()?.tags.push @name()
        viewModel.activeProduct()?.save()

window.Tag = Tag
