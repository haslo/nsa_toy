$(document).ready ->
  $search = $('#search')
  $search.focus()

  searchTimeout = undefined

  triggerSearch = ->
    clearTimeout searchTimeout  if searchTimeout
    searchTimeout = setTimeout(->
      if $search.val().length > 0
        ajaxOptions =
          url: '/search.json?q=' + $search.val()
          async: true
        $.ajax(ajaxOptions).done((data) ->
          $('#search-results').html(data['html'])
        )
    , 500)

  $search.change triggerSearch
  $search.keydown triggerSearch
  $search.keyup triggerSearch
