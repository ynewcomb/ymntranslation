# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
upload_form = undefined

$(".home.index").ready ->

  # init the select dropdown for length of translation
  try
    $(".fastselect").fastselect()
  catch e
    console.log "Couldn't load the dropdown menu"

  # init the date dropper
  try
    # $('#calendar').monthly({
    #   mode: 'picker',
    #   target: '#due-date',
    #   startHidden: true,
    #   showTrigger: '#due-date',
    #   stylePast: true,
    #   disablePast: true
    # });
    year = $("#cur_year").data("val")
    $( "#due-date" ).dateDropper({minYear: year, lang: "en", animate: false})
  catch e
    console.log "Couldn't load the date picker"

  validFields = (name, email, message, due_date, upload_data) ->
    all_good = true

    if name.length == 0
      $('#from-name').css 'border-bottom', '2px solid #c40022'
      $('#from-name-error').show()
      all_good = false
    else
      $('#from-name-error').hide()

    if email.length == 0
      $('#from-email').css 'border-bottom', '2px solid #c40022'
      $('#from-email-error').show()
      all_good = false
    else
      $('#from-email-error').hide()

    if message.length == 0
      $('#from-message').css 'border-bottom', '2px solid #c40022'
      $('#from-message-error').show()
      all_good = false
    else
      $('#from-message-error').hide()

    if upload_data == undefined
      all_good = false
      $('#upload_file').css 'border-bottom', '2px solid #c40022'
      $('#upload-file-error').show()
    else
      $('#upload-file-error').hide()

    if due_date.length == 0
      all_good = false
      $('#due-date').css 'border-bottom', '2px solid #c40022'
      $('#due-date-error').show()
    else
      $('#due-date-error').hide()

    return all_good  # will only be false if one of the check fails

  $('input, textarea').on 'keyup', (e) ->
    $(this).css 'border-bottom', '2px solid #049DBF'
    $(this).next().hide()
    return

  $('input').on 'blur', (e) ->
    # unhighlight input field
    $(this).css 'border-bottom', '2px solid #B2B2B2'
    return

  $('input').on 'focus', (e) ->
    # highlight input field
    $(this).css 'border-bottom', '2px solid #049DBF'
    return

  autosize = ->
    el = this
    el.style.cssText = 'height:auto; padding:0'
    # for box-sizing other than "content-box" use:
    # el.style.cssText = '-moz-box-sizing:content-box';
    el.style.cssText = 'height:' + el.scrollHeight + 'px'
    return

  $('textarea').on 'keyup', autosize

  # function that "translates" the page
  $('.spanish_eng_toggle').on 'click', (e) ->
    toggle_text = $(this).data('val')
    if toggle_text == 'ES'
      $(this).text 'EN'
      $(this).data 'val', 'EN'
    else
      $(this).text 'ES'
      $(this).data 'val', 'ES'
    return

  # Some global variables
  file_name = undefined
  upload_data = undefined

  # click handler for submit button
  $('#send').on 'click', ->
    sendEmail()
    return

  # function that sends an AJAX call to send email to YMN Translation
  sendEmail = () ->
    from_name = $('#from-name').val()
    email = $('#from-email').val()
    length = $("#fastselect-len").val()
    type = $("#fastselect-type").val()
    date = $("#due-date").val()
    message = $('#from-message').val()
    if validFields(from_name, email, message, date, upload_data)
      console.log "Sent email and uploaded file to dropbox"
      file_name = upload_data.files[0].name
      upload_data.submit()
      $.ajax
        url: '/send_request/'
        type: 'POST'
        data:
          "from_name": from_name
          "email":  email
          "translation_length": length
          "translation_type": type
          "file_name": file_name
          "due_date": date
          "message": message

        success: (response) ->
          hideTranslationRequest()
          console.log "Email sent successfully"

        error: (e) ->
          console.log "Error sending email due to server errors"

    else
      console.log "Did not send email or upload file to dropbox due to invalid fields"

    return

  hideTranslationRequest = () ->
    $('.form').addClass("fadeOutDown").one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', ->
      $(".thank_you").show()
      $(".thank_you").addClass("animated fadeInUp")
      $(this).hide()
      return

  # functions and code that deal with the file upload
  upload_form = $('#new_upload')
  upload_form.fileupload
    dataType: 'script'
    add: (e, data) ->
      # make sure the uploaded file is in doc/docx format
      types = /(\.|\/)(doc|docx)$/i
      file = data.files[0]
      file_name = file.name
      if types.test(file.type) or types.test(file.name)
        # when they select a file, we hide the upload interface cause
        # we don't want to upload to dropbox every time we select
        # a new file
        upload_form.hide()  # hide the upload mechanism
        $("#uploaded_file_name span").text(file_name)
        $(".uploaded_file_name_container").show()
        $('#upload-file-error').hide()

        upload_data = data
      else
        alertify.message(file_name + ' must be DOC or DOCX')
      return

  # show progress bar
  wrapper = $('.progress-wrapper')
  progress_bar = $('.progress-bar')
  upload_form.on 'fileuploadstart', ->
    wrapper.show()
    return

  upload_form.on 'fileuploaddone', ->
    wrapper.hide()
    progress_bar.width 0  # Revert progress bar's width back to 0 for future
    alertify.success('File uploaded')
    return

  upload_form.on 'fileuploadfail', ->
    wrapper.hide()
    progress_bar.width 0  # Revert progress bar's width back to 0 for future
    alertify.error('File failed to upload');
    return

  upload_form.on 'fileuploadprogressall', (e, data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    progress_bar.css('width', progress + '%').text progress + '%'
    return

  bitrate = wrapper.find('.bitrate')
  # show how fast the file is being uploaded
  upload_form.on 'fileuploadprogressall', (e, data) ->
    bitrate.text (data.bitrate / 1024).toFixed(2) + 'Kb/s'
    progress = parseInt(data.loaded / data.total * 100, 10)
    progress_bar.css('width', progress + '%').text progress + '%'
    return

  # code to handle the button to remove file from translation request
  $('.form').on 'click', '#uploaded_file_name', ->
    $(this).parent().hide()
    upload_form.show()
    upload_data = undefined
    file_name = undefined
    return
