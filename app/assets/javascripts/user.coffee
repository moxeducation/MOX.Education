class User
  constructor: (data) ->
    @cachedData = ko.observable()

    _.each ['id', 'email', 'companyName', 'role'], (field) =>
      @[field] = ko.observable()

    @persisted = ko.computed => @id()
    @isAdmin   = ko.computed => @role?() == 'admin'

    @update data if data

  update: (data) =>
    @cachedData data

    _.each ['id', 'email', 'companyName', 'role'], (field) =>
      @[field] data[field]

window.User = User
