jQuery ->
  paper.install(window)
  paper.setup('lattice')
  tool = new paper.Tool()

  canvas = document.getElementById('lattice')
  cx     = canvas.getContext('2d')
  circles = new Array()

  window.max_generations = 20
  window.latest_generation = 0
  window.generations = []

  $('#start').click ->
    $.getJSON 'start', null, (data, status) ->
      $('#start').hide()
      $('#running').show()
      $('#result_list ul').html('')
      setTimeout get_next_generation, 300
    false

  get_next_generation = ->
    $.getJSON 'next', null, (data, status) ->
      if data
        latest_generation = data.number
        li  = '<li id="' + data.number + '">'
        li += 'Generation#' + data.number + ', score: ' + data.score + '</li>'
        $('#result_list ul').append(li)
        show_on_lattice(data.agents)
        $('#result_list #' + data.number).hover (e)->
          display_generation(e.target.id)
        generations.push
          number: data.number,
          score: data.score,
          agents: data.agents
      if latest_generation < max_generations
        setTimeout get_next_generation, 300
      else
        $('#running').hide()
        $('#start').show()

  display_generation = (number)->
    gen = find_generation(number)
    show_on_lattice(gen.agents)
    un_highlight_generations()
    highlight_generation(number)

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
      x = agent.x * canvas.width / 8  # TODO don't hardcode this! & find reason for mvmt
      y = agent.y * canvas.height/ 8
      add_circle(new Point(x, y), 4, agent)
      paper.view.draw()

  add_circle = (centre, radius, agent) ->
    circle = new Path.Circle(centre, radius)
    circle.fillColor = 'black'
    circle.agent = agent
    circle.show_info = ->
      show_info(this.agent)
    circles.push(circle)

  clear_canvas = ->
    cx.clearRect(0, 0, canvas.width, canvas.height)
    project.activeLayer.removeChildren()
    circles.length = 0

  tool.onMouseMove = (event) ->
    # is a circle hit?
    # if so: find which one
    # and show its info
    hit_circle = null
    circles.some (circle, index, circles)->
      hit = circle.hitTest(event.point,
        fill: true,
        tolerance: 10
      )
      if hit
        hit_circle = circle
        return true
      else
        return false
    if hit_circle
      hit_circle.show_info()
    else
      hide_info()


  show_info = (agent)->
    $('#agent_info').text('Agent #' + agent.number + ': ')
      .append(agent.chromosome + '<br/>')
      .append('Score: ' + agent.score + '<br/>')
      .show()

  hide_info = ->
    $('#agent_info').hide()

  highlight_generation = (id)->
    $('ul#generations li#' + id).css("background-color", "yellow")

  un_highlight_generations = ->
    $('ul#generations li').css("background-color", "white")