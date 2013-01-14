jQuery ->
  canvas = document.getElementById('lattice')
  cx     = canvas.getContext('2d')

  circles = new Array()
  i = 0

  while i < 50
    circles[i] =
      x: Math.random() * canvas.width
      y: Math.random() * canvas.height
      r: Math.random() * 3
    i++
  (frame = ->
    canvas.width = canvas.width
    i = 50

    while i < 50
      circle = circles[i]
      cx.beginPath()
      cx.fillStyle = "black"
      cx.arc circle.x, circle.y, circle.r, 0, 2 * Math.PI
      cx.fill()
      i++
    # setTimeout frame, 100
  )()

  max_generations = 10
  latest_generation = 0

  $('#start').click ->
    $.getJSON 'start', null, (data, status) ->
      $('#start').hide()
      $('#running').show()
      $('#result_list ul').html('')
      setTimeout get_next_generation, 500
    false

  get_next_generation = ->
    $.getJSON 'next', null, (data, status) ->
      if data
        latest_generation = data.number
        li = '<li>Generation#' + data.number + ', score: ' + data.score + '</li>'
        $('#result_list').append(li)
      if latest_generation < max_generations
        setTimeout get_next_generation, 500
      else
        $('#running').hide()
        $('#start').show()

