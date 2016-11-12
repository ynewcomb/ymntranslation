document.addEventListener 'turbolinks:load', ->
  # Code to move the label from inside the input field to outside of it
  focusInputField = (elem) ->
    $parent = $(elem).parent()
    $parent.removeClass 'no-focus-with-text'
    $parent.removeClass 'no-focus'
    return

  $('.form_group_dynamic input, .form_group_dynamic textarea').on 'focus input', ->
    focusInputField this, true
    return

  unfocusInputField = (elem) ->
    $parent = $(elem).parent()
    if $(elem).val().length
      # we want to make sure that we change the color
      # of the label and input back to the base color
      # when the customer is no longer actively on that
      # field and they've entered data into the field.
      # NOTE: we return right after this, still leaving
      # the has-focus class on so the label don't block
      # the input field
      $parent.addClass 'no-focus-with-text'
      return
    $parent.addClass 'no-focus'
    $parent.removeClass 'no-focus-with-text'
    return

  $('.form_group_dynamic input, .form_group_dynamic textarea').on 'blur', ->
    unfocusInputField this
    return

  # edge case: upon page load, we want to put labels into fields that are empty
  $('.form_group_dynamic input, .form_group_dynamic textarea').each ->
    unfocusInputField this
    return
