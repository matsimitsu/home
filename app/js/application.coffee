$(document).ready ->
  $('[data-graph_source]').each ->
    target = @
    $.getJSON($(@).data('graph_source'), (res)=>
      window.render_sparkline(target, res)
    )

window.render_sparkline = (target, graph_data) ->
  w = $(target).width()
  h = $(target).height()

  getDate = (el) ->
    new Date(el.created_at)

  data = graph_data.sort((a,b) -> getDate(a)-getDate(b))
  top = d3.max(data, (d) -> d.count)
  x = d3.time.scale().domain([getDate(data[0]), getDate(data[data.length - 1])]).range([0, w])
  y = d3.scale.linear().domain([0, top]).range([h, 0])

  # create the area (closed path) that will be the response response time graph
  garea = d3.svg.area()
    .interpolate("linear")
    .x((d) ->
      x(getDate(d))
    )
    .y0(Math.max(h - 1, h))
    .y1((d) ->
      y(d.count)
    )

  graph = d3.select(target).append("svg:svg")
      .attr("width", w)
      .attr("height", h)
    .append("svg:g")
      .attr("transform", "translate(0,0)")

  # Add the line by appending an svg:path element with the data line we created above
  # do this AFTER the axes above so that the line is above the tick-lines
  graph.append("svg:path")
    .attr("d", garea(data))
    .attr("class", "area")
