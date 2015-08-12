#!/usr/bin/env coffee


class InitGraphics

	constructor: (game) ->
		@connections = new ConnectionGraphics(game)


class ConnectionGraphics

	constructor: (@game) ->
		@render()

	render: () ->
		$("svg#surface").remove()
		surface = $("""<svg id="surface"></svg>""")

		for [sys1, sys2] in @filter(@combinations(@game.systems))
			console.log [sys1, sys2]
			[[x1, y1], [x2, y2]] = @endpoints(sys1.pos, sys2.pos)
			conn = $("""<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}" class="connection" />""")
			surface.append(conn)

		@game.e.append(surface)
		surface.html(surface.html())

	combinations: (items) ->
		pairs = []
		len = items.length - 1
		for i in [0..len]
			for j in [i..len]
				if i != j
					pairs.push([ items[i], items[j] ])
		pairs

	filter: (systems) ->
		systems.filter (pair) ->
			pair[0].stars.filter( (st) -> st.size in (st2.size for st2 in pair[1].stars) ).length == 0

	endpoints: (a, b) ->
		d = ( a[i] - b[i] for i in [0, 1] )
		len = Math.sqrt( d[0]*d[0] + d[1]*d[1] )
		v = ( (i / len) * 50 for i in d )

		a2 = ( Math.round( a[i] - v[i] ) for i in [0, 1] )
		b2 = ( Math.round( b[i] + v[i] ) for i in [0, 1] )
		[a2, b2]
