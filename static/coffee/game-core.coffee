#!/usr/bin/env coffee


# Star system radius
sysradius = 50


# Player object
class Player

	constructor: (current) ->
		@id = current.id
		@name = current.name
		@actions = current.actions

	isActive: () ->
		@actions != 0


# Base class of all drawable objects
class Element

	constructor: (e) ->
		@e = $(e)

	render: (surface) ->
		surface.append(@e)

	click: (key, handler, e = @e) ->
		e.on "click.#{key}", (event) ->
			e.addClass("selected")
			handler(event)
		if not e.hasClass("selectable") then e.addClass("selectable") else @overload = true

	unclick: (key, e = @e) ->
		e.off("click.#{key}")
		if not @overload then e.removeClass("selectable") else @overload = false

	remove: () ->
		@e.detach()


# Container for unused game pieces
class Stash extends Element

	constructor: (current) ->
		@stack = {
			red: ((new Stashed(s) for s in current.red[i]) for i in [0..2]),
			green: ((new Stashed(s) for s in current.green[i]) for i in [0..2]),
			blue: ((new Stashed(s) for s in current.blue[i]) for i in [0..2]),
			yellow: ((new Stashed(s) for s in current.yellow[i]) for i in [0..2])
		}
		super("""
			<div id="stash-wrapper">
				<table id="stash">
				</table>
			</div>
		""")

	render: (surface) ->
		for color, pieces of @stack
			tr = $("""<tr class="stash-#{color}"></tr>""")
			for size in [1..3]
				td = $("""<td class="stash-#{size}"></td>""")
				for piece in pieces[size - 1]
					piece.render(td)
				tr.append(td)
			@e.find("#stash").append(tr)
		super(surface)

	click: (color, size, args...) ->
		super(args..., @e.find("tr.stash-#{color} > td.stash-#{size}"))

	unclick: (args...) ->
		super(args..., @e.find("td"))

	add: (obj) ->
		stashed = new Stashed(obj)
		@stack[obj.color][obj.size - 1].push(stashed)
		stashed.render(@e.find(".stash-#{stashed.color} .stash-#{stashed.size}"))

	getShip: (obj) ->
		stashed = @stack[obj.color][obj.size - 1].pop()
		stashed.remove()
		new Ship(stashed)

	getStar: (obj) ->
		stashed = @stack[obj.color][obj.size - 1].pop()
		stashed.remove()
		new Star(stashed)


# Base class for game pieces
class Stashable extends Element

	constructor: (type) ->
		super("""
			<span class="#{type} #{@color} size-#{@size}">
			</span>
		""")

	destroy: () ->
		@remove()
		game.stash.add(@)


# Stashed game piece
class Stashed extends Stashable

	constructor: (current) ->
		@color = current.color
		@size = current.size
		super("stashed")


# Game piece as star
class Star extends Stashable

	constructor: (current) ->
		@color = current.color
		@size = current.size
		super("star")


# Game piece as ship
class Ship extends Stashable

	constructor: (current) ->
		@color = current.color
		@size = current.size
		super("ship")


# Solar system containing one or mutiple stars + ships of both players
class System extends Element

	constructor: (current) ->
		@pos = current.pos
		@home = current.home
		@stars = (new Star(s) for s in current.stars)
		@ships = {
			1: (new Ship(s) for s in current.ships[1]),
			2: (new Ship(s) for s in current.ships[2])
		}
		super("""
			<div class="system-clear" style="top: #{@pos[1] - sysradius*2}px; left: #{@pos[0] - sysradius*2}px;">
				<div class="system #{'system-home' if @home}">
					<div class="ships-left"></div>
					<div class="stars"></div>
					<div class="ships-right"></div>
				</div>
			</div>
		""")

	render: (surface) ->
		star.render(@e.find(".stars")) for star in @stars
		ship.render(@e.find(".ships-right")) for ship in @ships[1]
		ship.render(@e.find(".ships-left")) for ship in @ships[2]
		super(surface)

	click: (args...) ->
		super(args..., @e.find(".system"))

	unclick: (args...) ->
		super(args..., @e.find(".system"))

	addShip: (player, ship) ->
		@ships[player.id].push(ship)
		ship.render(@e.find([".ships-right", ".ships-left"][player.id - 1]))

	getShip: (player, ship) ->
		index = @ships[player.id].indexOf(ship) # not working
		ship = @ships[player.id].splice(index, 1)[0]
		if @ships[1].length + @ships[2].length == 0
			@destroy()
		else
			ship.remove()
		ship

	removeStar: (star) ->
		index = @stars.indexOf(star) # not working
		@stars.splice(index, 1)[0].destroy()
		if stars.length == 0
			@destroy()

	destroy: () ->
		@remove()
		star.destroy() for star in @stars
		ship.destroy() for ship in @ships[1]
		ship.destroy() for ship in @ships[2]


# Container for all game objects, constructor accepts current game status
class Game extends Element

	constructor: (current) ->
		@players = (new Player(p) for p in current.players)
		@systems = (new System(s) for s in current.systems)
		@stash = new Stash(current.stash)
		super("""
			<div id="game">
			</div>
		""")

	render: (surface) ->
		system.render(@e) for system in @systems
		@stash.render(@e)
		super(surface)

	getActivePlayer: () ->
		@players.filter( (p) ->
			p.isActive()
		).pop()

	getInactivePlayer: () ->
		@players.filter( (p) ->
			not p.isActive()
		).pop()

	newSystem: (star, pos) ->
		system = new System({
			pos: pos,
			stars: [star],
			ships: { 1: [], 2: [] }
		})
		@systems.push(system)
		system.render(@e)
		graphics.render(@e) if graphics
		system

	toJson: () ->
		JSON.stringify(@)
