ko.bindingHandlers.htmlLazy =
  update: (element, valueAccessor) ->
    value = ko.unwrap valueAccessor()
    element.innerHTML = value

ko.bindingHandlers.placeholder =
  init: (element, valueAccessor, allBindingsAccessor) ->
    value = ko.unwrap valueAccessor()
    $(element).on 'focus', ->
      if $(element).hasClass 'placeholder'
        $(element).removeClass 'placeholder'
        element.innerHTML = ''
    $(element).on 'blur', ->
      if element.innerText.trim() == ''
        $(element).addClass 'placeholder'
        element.innerHTML = value
  update: (element, valueAccessor) ->
    value = ko.unwrap valueAccessor()
    if element.innerText.trim() == ''
      $(element).addClass 'placeholder'
      element.innerHTML = value
    else
      $(element).removeClass 'placeholder'

ko.bindingHandlers.contentEditable =
  init: (element, valueAccessor, allBindingsAccessor) ->
    value = ko.unwrap valueAccessor()
    htmlLazy = allBindingsAccessor().htmlLazy
    $(element).on 'blur', ->
      htmlLazy @innerHTML if @isContentEditable && ko.isWriteableObservable(htmlLazy)
  update: (element, valueAccessor) ->
    value = ko.unwrap valueAccessor()
    element.contentEditable = value
    $(element).trigger 'blur' if !element.isContentEditable

ko.bindingHandlers.file = 
  init: (element, valueAccessor, allBindingsAccessor) ->
    if typeof valueAccessor() == 'function'
      fileContents = valueAccessor()
    else
      rawFile = valueAccessor()['file']
      fileContents = valueAccessor()['data']
      fileName = valueAccessor()['name']

    reader = new FileReader()
    reader.onloadend = -> fileContents reader.result

    $(element).on 'change', ->
      file = element.files[0]

      if file
        rawFile file if rawFile
        reader.readAsDataURL file
        fileName file.name if fileName
      else
        rawFile null if rawFile
        fileContents null if fileContents
        fileName null if fileName

ko.bindingHandlers.wysiwyg =
  init: (element, valueAccessor, allBindingsAccessor) ->
    txtBoxId = $(element).attr 'id'

    config = {}
    config.toolbarGroups = [
      { name: 'document', groups: [ 'mode', 'document', 'doctools' ] },
      { name: 'clipboard', groups: [ 'clipboard', 'undo' ] },
      { name: 'editing', groups: [ 'find', 'selection', 'spellchecker', 'editing' ] },
      { name: 'forms', groups: [ 'forms' ] },
      { name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi', 'paragraph' ] },
      { name: 'links', groups: [ 'links' ] },
      '/',
      { name: 'styles', groups: [ 'styles' ] },
      { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
      { name: 'colors', groups: [ 'colors' ] },
      '/',
      { name: 'insert', groups: [ 'insert' ] },
      { name: 'tools', groups: [ 'tools' ] },
      { name: 'others', groups: [ 'others' ] },
      { name: 'about', groups: [ 'about' ] }
    ];

    config.removeButtons = 'Source,Save,NewPage,Preview,Print,Templates,Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,Scayt,SelectAll,Find,Replace,CreateDiv,Blockquote,BidiLtr,BidiRtl,Language,Image,Flash,Table,HorizontalRule,PageBreak,Iframe,Smiley,SpecialChar,Maximize,ShowBlocks,About,Styles,Anchor';

    # Little hack
    autosize = ->
      setTimeout ->
        return unless CKEDITOR.instances[txtBoxId]
        try
          CKEDITOR.instances[txtBoxId].resize $(element).parent().width(), $(element).parent().height()
          $(window).one 'resize', autosize
        catch error
          CKEDITOR.instances[txtBoxId].destroy true
      , 250
    $(window).one 'resize', autosize

    ko.utils.domNodeDisposal.addDisposeCallback element, ->
      CKEDITOR.remove CKEDITOR.instances[txtBoxId] if CKEDITOR.instances[txtBoxId]
      $(window).off 'resize', autosize

    value = ko.unwrap valueAccessor()
    element.innerHTML = value

    CKEDITOR.replace element, config
    CKEDITOR.instances[txtBoxId].on 'instanceReady', autosize
    CKEDITOR.instances[txtBoxId].focusManager.blur = ->
      observable = valueAccessor()
      observable CKEDITOR.instances[txtBoxId].getData()
  update: (element, valueAccessor) ->
    value = ko.utils.unwrapObservable valueAccessor()
    $(element).val value

ko.bindingHandlers.spectrum =
  init: (element, valueAccessor, allBindingsAccessor) ->
    value = ko.unwrap valueAccessor()

    $(element).spectrum
      color: value
      showInput: true
      showInitial: true
      showPalette: true
      showSelectionPalette: true
      preferredFormat: 'hex'
      change: (color) ->
        valueAccessor() color.toHexString()
      palette: [
        ["rgb(0, 0, 0)", "rgb(67, 67, 67)", "rgb(102, 102, 102)",
        "rgb(204, 204, 204)", "rgb(217, 217, 217)","rgb(255, 255, 255)"],
        ["rgb(152, 0, 0)", "rgb(255, 0, 0)", "rgb(255, 153, 0)", "rgb(255, 255, 0)", "rgb(0, 255, 0)",
        "rgb(0, 255, 255)", "rgb(74, 134, 232)", "rgb(0, 0, 255)", "rgb(153, 0, 255)", "rgb(255, 0, 255)"], 
        ["rgb(230, 184, 175)", "rgb(244, 204, 204)", "rgb(252, 229, 205)", "rgb(255, 242, 204)", "rgb(217, 234, 211)", 
        "rgb(208, 224, 227)", "rgb(201, 218, 248)", "rgb(207, 226, 243)", "rgb(217, 210, 233)", "rgb(234, 209, 220)", 
        "rgb(221, 126, 107)", "rgb(234, 153, 153)", "rgb(249, 203, 156)", "rgb(255, 229, 153)", "rgb(182, 215, 168)", 
        "rgb(162, 196, 201)", "rgb(164, 194, 244)", "rgb(159, 197, 232)", "rgb(180, 167, 214)", "rgb(213, 166, 189)", 
        "rgb(204, 65, 37)", "rgb(224, 102, 102)", "rgb(246, 178, 107)", "rgb(255, 217, 102)", "rgb(147, 196, 125)", 
        "rgb(118, 165, 175)", "rgb(109, 158, 235)", "rgb(111, 168, 220)", "rgb(142, 124, 195)", "rgb(194, 123, 160)",
        "rgb(166, 28, 0)", "rgb(204, 0, 0)", "rgb(230, 145, 56)", "rgb(241, 194, 50)", "rgb(106, 168, 79)",
        "rgb(69, 129, 142)", "rgb(60, 120, 216)", "rgb(61, 133, 198)", "rgb(103, 78, 167)", "rgb(166, 77, 121)",
        "rgb(91, 15, 0)", "rgb(102, 0, 0)", "rgb(120, 63, 4)", "rgb(127, 96, 0)", "rgb(39, 78, 19)", 
        "rgb(12, 52, 61)", "rgb(28, 69, 135)", "rgb(7, 55, 99)", "rgb(32, 18, 77)", "rgb(76, 17, 48)"]
      ]
  update: (element, valueAccessor) ->
    value = ko.unwrap valueAccessor()
    $(element).spectrum 'set', value
