# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
upload_form = undefined
document.addEventListener 'turbolinks:load', ->
  # uncheck the checkbox
  $("#file-skip-checkbox")[0].checked = false
  # Clear the text area
  $("textarea, #from-name, #from-email").val("")
  try
    $('input[type=file]').bootstrapFileInput();
  catch e
    console.error e

  validFields = (name, email, phone, message, due_date, upload_data, skip_sample_file) ->
    all_good = true

    if name.length == 0
      $('#from-name').css 'border', '1px solid #c40022'
      $('#from-name-error').show()
      all_good = false
    else
      $('#from-name-error').hide()

    if email.length == 0
      if phone.length == 0
        $('#from-email').css 'border', '1px solid #c40022'
        # only show the email error if phone is also empty
        $('#from-email-error').show()
    else
      $('#from-email-error').hide()
      $('#from-number-error').hide()

    if phone.length == 0
      if email.length == 0
        $('#from-number').css 'border', '1px solid #c40022'
        # only show the phone error if email is also empty
        $('#from-number-error').show()
    else
      $('#from-email-error').hide()
      $('#from-number-error').hide()

    if email.length == 0 and phone.length == 0
      all_good = false

    if message.length == 0
      $('#from-message').css 'border', '1px solid #c40022'
      $('#from-message-error').show()
      all_good = false
    else
      $('#from-message-error').hide()

    if !skip_sample_file
      # the user hasn't checked the "Don't Send a Sample" box
      if upload_data == undefined
        all_good = false
        $('#upload_file').css 'border', '1px solid #c40022'
        $('#upload-file-error').show()
      else
        $('#upload-file-error').hide()
    else
      $('#upload-file-error').hide()

    if due_date.length == 0
      all_good = false
      $('#due-date').css 'border', '1px solid #c40022'
      $('#due-date-error').show()
    else
      $('#due-date-error').hide()

    return all_good  # will only be false if one of the check fails

  $('input').on 'keyup', (e) ->
    $(this).css 'border-bottom', '1px solid #37A8E0'
    $(this).next().hide()
    if $(this).attr("id") == 'from-email'
      # case: user is typing into the email field
      # we want to check the length of the email field
      # and check if has anything in it. If it does, we
      # can remove the errors from the phone field
      if $("#from-email").val().length != 0
        $("#from-number").css 'border', '1px solid #37A8E0'
        $('#from-number-error').hide()
    else if $(this).attr("id") == 'from-number'
      # case: we do the reverse of above; now we are on
      # the phone field
      if $("#from-number").val().length != 0
        $("#from-email").css 'border', '1px solid #37A8E0'
        $('#from-email-error').hide()
    return

  $('textarea').on 'keyup', (e) ->
    $(this).css 'border', '1px solid #37A8E0'
    $(this).next().hide()
    return

  $('input').on 'blur', (e) ->
    # unhighlight input field
    $(this).css 'border', '1px solid #B2B2B2'
    return

  $('input').on 'focus', (e) ->
    # highlight input field
    $(this).css 'border', '1px solid #37A8E0'
    return

  $('textarea').on 'blur', (e) ->
    # unhighlight input field
    $(this).css 'border', '1px solid #B2B2B2'
    return

  $('textarea').on 'focus', (e) ->
    # highlight input field
    $(this).css 'border', '1px solid #37A8E0'
    return

  $.each jQuery('textarea[data-autoresize]'), ->
    offset = @offsetHeight - (@clientHeight)

    resizeTextarea = (el) ->
      $(el).css('height', 'auto').css 'height', el.scrollHeight + offset
      return

    $(this).on('keyup input', ->
      resizeTextarea this
      return
    ).removeAttr 'data-autoresize'
    return

  # function that "translates" the page
  $('.spanish_eng_toggle').on 'click', (e) ->
    toggle_text = $(this).data('val')
    $(this).hide()
    Turbolinks.visit("?lang=#{toggle_text}")

  # Some global variables
  file_name = undefined
  upload_data = undefined
  from_name = undefined
  email = undefined
  phone = undefined
  length = undefined
  type = undefined
  date = undefined
  message = undefined
  skip_sample_file = false

  # Click handler for checkbox
  $("#file-skip-checkbox").on 'change', (e) ->
    $('#upload-file-error').hide()
    skip_sample_file = $(@)[0].checked
    if skip_sample_file
      $(".control-group").css("margin-top", "-10px")
      $(".upload_file_container").hide()
    else
      $(".control-group").css("margin-top", "0px")
      $(".upload_file_container").show()

  # click handler for submit button
  $('#send').on 'click', ->
    sendEmail()
    return

  # function that sends an AJAX call to send email to YMN Translation
  sendEmail = () ->
    from_name = $('#from-name').val()
    email = $('#from-email').val()
    phone = $('#from-number').val()
    length = $("#fastselect-len").val()
    type = $("#fastselect-type").val()
    date = $("#due-date").val()
    message = $('#from-message').val()
    if validFields(from_name, email, phone, message, date, upload_data, skip_sample_file)
      console.log "Sent email and uploaded file to dropbox"
      if !skip_sample_file
        # user is uploading a file
        file_name = upload_data.files[0].name
        upload_data.submit()
      else
        # user wants to skip sending a sample file so we call ajax directly
        sendAjax()
      $("#send").hide()
      $(".spinner").show()
    else
      console.log "Did not send email or upload file to dropbox due to invalid fields"

  hideTranslationRequest = () ->
    $(".spinner").hide()
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
        $(".control-group").hide()  # hide the "Dont Send a Sample" text
        $("#uploaded_file_name span").text(file_name)
        $(".uploaded_file_name_container").show()
        $('#upload-file-error').hide()

        upload_data = data
      else
        alertify.error('File must be DOC or DOCX')
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
    # we only send the ajax request to send the email if we successfully
    # uploaded the file.
    sendAjax()
    return

  upload_form.on 'fileuploadfail', ->
    wrapper.hide()
    progress_bar.width 0  # Revert progress bar's width back to 0 for future
    alertify.error('File failed to upload');
    return

  # show how fast the file is being uploaded
  upload_form.on 'fileuploadprogressall', (e, data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    progress_bar.css('width', progress + '%').text progress + '%'
    return

  # function to send AJAX call
  sendAjax = () ->
    $.ajax
      url: '/send_request/'
      type: 'POST'
      data:
        "from_name": from_name
        "email":  email
        "phone":  phone
        "translation_length": length
        "translation_type": type
        "file_name": file_name
        "due_date": date
        "message": message
        "skip": skip_sample_file

      success: (response) ->
        hideTranslationRequest()
        console.log "Email sent successfully"

      error: (e) ->
        console.log "Error sending email due to server errors"

  # code to handle the button to remove file from translation request
  $('.form').on 'click', '#uploaded_file_name', ->
    $(this).parent().hide()
    $(".control-group").show()
    upload_form.show()
    upload_data = undefined
    file_name = undefined
    return

  # init the select dropdown for length of translation
  try
    $(".fastselect").fastselect()
  catch e
    console.error "Couldn't load the dropdown menu"
