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

  $('nav a').on 'click', (e) ->
    e.preventDefault()
    window.location = $(@).attr("href")
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
  colorTo = target.attr('color-to')
  colorFrom = target.attr('color-from')
  w = target.width() - 50
  h = target.height() - 50

  getDate = (el) ->
    new Date(el.ts)

  data = graph_data.data.sort((a,b) -> getDate(a)-getDate(b))
  from = new Date(graph_data.from)
  to = new Date(graph_data.to)
  timeframe = graph_data.timeframe

  scale = d3.time.scale.utc().domain([from, to])
  ticks = switch timeframe
    when 'hour' then scale.ticks(d3.time.minutes, 1)
    when 'day' then scale.ticks(d3.time.hours, 1)
    when 'week' then scale.ticks(d3.time.hours, 1)
    when 'month' then scale.ticks(d3.time.days, 1)
    when 'year' then scale.ticks(d3.time.days, 1)

  bin_width = Math.floor(w / (ticks.length ))
  top = d3.max(data, (d) -> d.count)

  # Adjust the tick count depending on data size
  if (data.length > 0 && top > 0 )
    tick_count = 4
  else
    tick_count = 4
    top = 1

  x = d3.time.scale.utc().domain([from, to]).range([0, (w - bin_width)])
  y = d3.scale.linear().domain([0, top]).range([h, 0])

  full_data = []

  # Make sure missing points are added to the data
  for date, i in ticks
    point = graph_data.data.filter((x) =>
      getDate(x).getTime() == date.getTime()
    )[0]
    full_data.push({
      ts: date,
      count: if point then point.count else 0
    })

  graph = d3.select(target[0]).append("svg:svg")
      .attr("width", w + 50)
      .attr("height", h + 50)

  gradient = graph.append("linearGradient")
      .attr('id', "#{colorFrom}#{colorTo}")
      .attr('y1', h)
      .attr('y2', 0)
      .attr('x1', 0)
      .attr('x2', 0)
      .attr("gradientUnits", "userSpaceOnUse")

  gradient
        .append("stop")
          .attr("stop-color", colorFrom)
  gradient
        .append("stop")
          .attr("offset": '100%')
          .attr("stop-color", colorTo)


  t = graph.append("svg:g")
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
  t.append("svg:g")
    .attr({
      class: "y axis",
      transform: "translate(0,0)"
    })
    .call(yAxisLeft)


  # create x-axis
  xAxis = xAxisBase()
    .tickSize(6, 0, 0)
    .tickSubdivide(true)
    .tickPadding(9)
    .tickFormat( (d) -> moment(d).format('HH:mm'));
  # Add the x-axis to the graph
  t.append("svg:g")
    .attr({
      class: "x axis",
      transform: "translate(0," + (h) + ")"
    })
    .call(xAxis);

  line = d3.svg.line()
    .x( (d) ->  x(d.ts) )
    .y( (d) ->  y(d.count) )
    .interpolate('monotone')

  t.append("path")
      .datum(full_data)
      .attr("class", "line")
      .attr("d", line)
      .attr('style', "stroke: url(##{colorFrom}#{colorTo})")
  #response_bar = graph.selectAll(".bar")
  #    .data(full_data)
  #    .enter().append("g")
  #      .attr({
  #        class: "bar",
  #        transform: "translate(0,0)"
  #      })
#
  ## draw rects for the response time bars
  #response_bar.append("rect")
  #  .attr({
  #    x: (d, i) ->  (i * (bin_width + .5)),
  #    y: (d) ->   y(d.count),
  #    width: bin_width,
  #    height: (d, i) -> h - y(d.count)
  #  })
#
