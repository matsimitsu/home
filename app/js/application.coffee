$(document).ready ->

  updateHeader = () ->
    $.getJSON "/api/meters", (res) =>
      $('.mod-header-meters .electricity').html(res.electricity)
      $('.mod-header-meters .gas').html(res.gas)
      $('.mod-header-meters .water').html(res.water)
      $('.mod-header-meters .time').html(moment().format('DD-MM-YYYY hh:mm'))

    setTimeout ( ->
      updateHeader()
    ), 30000

  updateHeader()

  select = $('.timeframe-select')
  select.on 'change', ->
    window.graph_from_timeframe_select($(@).val())

  graph_from_timeframe_select(select.val())

  $('.devices a').on 'click', (e) ->
    e.preventDefault
    $.getJSON $(@).attr('href')
    false

  now = new Date()
  recoverFromSleep = () ->
    new_now = new Date()
    diff = new_now.getTime() - now.getTime()

    if diff > 30000
      updateHeader()
      if $('.timeframe-select').length > 0
        graph_from_timeframe_select(select.val())

    now = new_now
    setTimeout ( ->
      recoverFromSleep()
    ), 1000
  recoverFromSleep()

window.graph_from_timeframe_select = (val) ->
  $('[data-graph_source]').each ->
    target = @
    url = "/api/graphs/#{$(@).data('graph_source')}/#{val}"
    $.getJSON(url, (res) =>
      window.render_meter(target, res)
    )

window.render_meter = (meter, graph_data) ->
  $(meter).find('.number').html(graph_data.total)
  target = $(meter).find('.history')
  target.html('')
  w = target.width() - 50
  h = target.height() - 50

  getDate = (el) ->
    new Date(el.ts)

  data = graph_data.data.sort((a,b) -> getDate(a)-getDate(b))
  from = new Date(graph_data.from)
  to = new Date(graph_data.to)
  timeframe = graph_data.timeframe

  scale = d3.time.scale().domain([from, to])
  ticks = switch timeframe
    when 'hour' then scale.ticks(d3.time.minutes, 1)
    when 'day' then scale.ticks(d3.time.hours, 1)
    when 'week' then scale.ticks(d3.time.hours, 1)
    when 'month' then scale.ticks(d3.time.hours, 24)
    when 'year' then scale.ticks(d3.time.hours, 24)

  bin_width = Math.floor(w / (ticks.length ))
  top = d3.max(data, (d) -> d.count)

  # Adjust the tick count depending on data size
  if (data.length > 0 && top > 0 )
    tick_count = 4
  else
    tick_count = 4
    top = 1

  x = d3.time.scale().domain([from, to]).range([0, (w - bin_width)])
  y = d3.scale.linear().domain([0, top]).range([h, 0])

  full_data = []

  # Make sure missing points are added to the data
  for date, i in ticks
    point = graph_data.data.filter((x) =>
     getDate(x).getTime() == date.getTime()
    )[0]
    if point
      full_data.push(point)
    else
      full_data.push({'ts': date, 'count': 0})

  graph = d3.select(target[0]).append("svg:svg")
      .attr("width", w + 50)
      .attr("height", h + 50)
    .append("svg:g")
      .attr("transform", "translate(50,10)")

  xAxisBase = () ->
    d3.svg.axis()
      .scale(x)
      .ticks(8)

  yAxisBase = () ->
    d3.svg.axis()
      .scale(y)
      .ticks(tick_count)
      .orient("left")

  # create y-axis
  yAxisLeft = yAxisBase()
    .tickSubdivide(false)
    .orient("left")

  # Add the y-axis to the graph
  graph.append("svg:g")
    .attr({
      class: "y axis",
      transform: "translate(0,0)"
    })
    .call(yAxisLeft)

  graph.append("svg:g")
    .classed("y grid", true)
    .call(
      yAxisBase()
        .tickSize(-w,0,0)
        .tickFormat("")
    )

  # create x-axis
  xAxis = xAxisBase()
    .tickSize(6, 0, 0)
    .tickSubdivide(true)
    .tickPadding(9)

  # Add the x-axis to the graph
  graph.append("svg:g")
    .attr({
      class: "x axis",
      transform: "translate(0," + (h) + ")"
    })
    .call(xAxis);

  response_bar = graph.selectAll(".bar")
      .data(full_data)
      .enter().append("g")
        .attr({
          class: "bar",
          transform: "translate(0,0)"
        })

  # draw rects for the response time bars
  response_bar.append("rect")
    .attr({
      x: (d, i) ->  (i * (bin_width + .5)),
      y: (d) ->   y(d.count),
      width: bin_width,
      height: (d, i) -> h - y(d.count)
    })

