#= require jquery
#= require jquery_ujs
#= require jquery.form.min
#= require knockout
#= require knockout-bindings
#= require underscore
#= require grid
#= require video
#= require mobile-detect
#= require perfect-scrollbar.jquery.min
#= require noty/jquery.noty
#= require noty/layouts/topRight
#= require noty/themes/default
#= require native.history
#= require lightbox
#
#= require view-model

# some util functions
window.sortByOrder = (a, b) ->
  return -1 if a.order() < b.order()
  return 1 if a.order() > b.order()
  0

window.generateColor = ->
  while !q || parseInt(88 + q * (-0.589) - 10) < 0 || parseInt(55 + q * (-0.089) - 10) < 0
    q = parseInt Math.random() * 255
  "hsl(#{q}, #{parseInt 88 + q * (-0.589)}%, #{parseInt 55 + q * (-0.089)}%)"

unless String.prototype.startsWith
  String.prototype.startsWith = (prefix) -> @.indexOf(prefix) == 0

$ ->
  window.viewModel = new AppViewModel
  ko.applyBindings(viewModel)

  $('.tile').perfectScrollbar()

  lightbox.build()
  $(document).on 'click', 'a[data-lightbox]', ->
    lightbox.start $(this)
    false

  # some kind of hack :-\
  showNextError = true

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

  $('#profile form').on 'ajax:success', (e, data) ->
    $('#dialog-wrapper').fadeOut()
    noty
      text: "Profile was successfully updated."
      type: 'success'
      timeout: 3000
  $('#profile form').on 'ajax:error', (e, xhr, status, error) ->
    $('#profile .error').remove()
    data = xhr.responseJSON
    if data?.errors
      first = false
      for field, error of data.errors
        first = field unless first
        $('<span class="error" />').text(error[0]).insertAfter $('#profile #user_' + field)
      $('#profile #user_' + first).focus()

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

#    noty
#      text: "We are sorry, but something went wrong.<br>Please refresh page and try again."
#      type: 'error'
#      timeout: 10000

  $(document).on 'click', '#save_button', ->
    $(this).find('i').removeClass('fa-floppy-o')
    $(this).find('i').addClass('fa fa-spinner fa-spin fa-lg')
