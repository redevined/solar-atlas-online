#!/usr/bin/env coffee


# Star system radius
sysradius = 50


class Graphics

	constructor: (game, settings) ->
		@features = []
		@features.push(new ConnectionGraphics(game)) if settings.connections
		@features.push(new OrbitGraphics(game)) if settings.orbits
		
		surface = $("""<svg id="surface"></svg>""")
		game.e.append(surface)
		@render(surface)

	render: (surface) ->
		surface.empty()
		for feature in @features
			feature.render(surface)
		surface.html(surface.html())


class ConnectionGraphics

	constructor: (@game) ->

	render: (surface) ->
		for [sys1, sys2] in @filter(@combinations(@game.systems))
			[[x1, y1], [x2, y2]] = @endpoints(sys1.pos, sys2.pos)
			conn = $("""
				<line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}" class="connection" />
			""")
			surface.append(conn)

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
		v = ( (i / len) * sysradius for i in d )

		a2 = ( Math.round( a[i] - v[i] ) for i in [0, 1] )
		b2 = ( Math.round( b[i] + v[i] ) for i in [0, 1] )
		[a2, b2]


class OrbitGraphics

	constructor: (@game) ->

	render: (surface) ->
		for system in @game.systems
			[x, y] = system.pos
			orbit = $("""
				<g transform="translate(#{x},#{y})">
				</g>
			""")

			for i in [0..@random(0, 2)]
				[cx, cy] = @randomPos(sysradius)
				size = @random(4, 10)
				time = @random(50, 100) / 10
				orbiter = $("""
					<circle cx="#{cx}" cy="#{cy}" r="#{size}" class="orbiter" style="animation-duration: #{time}s;" />
				""")

				orbit.append(orbiter)
			surface.append(orbit)

	random: (min, max) ->
		Math.round(Math.random() * (max - min)) + min

	randomPos: (r) ->
		rad = Math.random() * 2 * Math.PI
		( Math.round(r * trig(rad)) for trig in [Math.sin, Math.cos] )
