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

  window.max_generations = 10
  window.latest_generation = 0
  window.generations = []

  $('#start').click ->
    $.getJSON 'start', null, (data, status) ->
      $('#start').hide()
      $('#running').show()
      $('#result_list ul').html('')
      setTimeout get_next_generation, 100
    false

  get_next_generation = ->
    $.getJSON 'next', null, (data, status) ->
      if data
        latest_generation = data.number
        li  = '<li id="' + data.number + '">'
        li += 'Generation#' + data.number + ', score: ' + data.score + '</li>'
        $('#result_list').append(li)
        $('#result_list #' + data.number).hover (e)->
          display_generation(e.target.id)
        generations.push
          number: data.number,
          score: data.score,
          agents: data.agents
      if latest_generation < max_generations
        setTimeout get_next_generation, 100
      else
        $('#running').hide()
        $('#start').show()

  display_generation = (number)->
    gen = find_generation(number)
    show_on_lattice(gen.agents)

  find_generation = (number)->
    found = null
    generations.forEach (generation, index, array)->
      if generation.number is parseInt(number)
        found = generation
        return
    return found if found
    console.log 'No generation with number ' + number + ' found.'
    return null

  show_on_lattice = (agents) ->
    clear_canvas()
    agents.forEach (agent, index, agents)->
      x = agent.x * canvas.width / 4  # TODO don't hardcode this! & find reason for mvmt
      y = agent.y * canvas.height/ 4
      cx.beginPath()
      cx.fillStyle = "black"
      cx.arc x, y, 2, 0, 2 * Math.PI
      cx.fill()


  clear_canvas = ->
    cx.clearRect(0, 0, canvas.width, canvas.height);
