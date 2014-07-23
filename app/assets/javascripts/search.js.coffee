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
          if data.length > 0
            console.log data
            console.log data[0]['href']
          else
            console.log 'no data'
        )
    , 500)

  $search.change triggerSearch
  $search.keydown triggerSearch
  $search.keyup triggerSearch
