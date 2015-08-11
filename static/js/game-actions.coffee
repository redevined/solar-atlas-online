#!/usr/bin/env coffee


class Actions

	constructor: (@game) ->
		@players = {
			active: @game.getActivePlayer(),
			inactive: @game.getInactivePlayer()
		}


class InitActions extends Actions

	constructor: (game) ->
		super(game)
		@actions = {
			attack: new AttackActions(game),
			build: new BuildActions(game),
			trade: new TradeActions(game),
			move: new MoveActions(game)
		}
		@setSystemsSelectable()

	# Set all solar system selectable
	setSystemsSelectable: () ->
		for system in @game.systems
			system.click "select", () ->
				setActionsSelectable(system)

				system.unclick("select") for system in @game.systems

	# Set all stars and own ships in a system selectable
	setActionsSelectable: (system) ->
		pieces = system.stars + system.ships[@players.active.id]
		for piece in pieces
			piece.click "action", () ->
				getAction(piece)(system)

				piece.unclick("action") for piece in pieces

	# Get piece action depending on color
	getAction: (piece) ->
		switch piece.color
			when "red" then @actions.attack.setShipsCaptureable
			when "green" then @actions.build.setStashBuildable
			when "blue" then @actions.trade.setShipsTradable
			when "yellow" then @actions.move.setShipsMoveable


class AttackActions extends Actions

	# Set all ships in the same system attackable
	setShipsCaptureable: (system) ->
		ships = system.ships[@player.inactive.id].filter (s) ->
			s.size <= Math.max.apply(null, (sh.size for sh in system.ships[@player.active.id]))

		for ship in ships
			ship.click "attack", () =>
				attack(system, origin, ship)

				ship.unclick("attack") for ship in ships


class BuildActions extends Actions

	# Set stash rows with matching colors in the current system selectable
	setStashBuildable = (system) ->
		colors = (ship.color for ship in system.ships[@player.active.id])

		for color, row of @game.stash.stack
			if color in colors and row.filter( (r) -> r.length > 0).length > 0
				@game.stash.clickRow color, "build", () =>
					build(system, row)

					@game.stash.unclickRows("build")


class TradeActions extends Actions

	# Make own ships tradable
	setShipsTradable = (system) ->
		ships = system.ships[@player.active.id]

		for ship in ships
			ship.click "trade_ship", () ->
				setStashTradable(system, ship)

				ship.unclick("trade_ship") for ship in ships

	# Set stash rows clickable for trading
	setStashTradable = (system, ship) ->
		for color, row of @game.stash.stack
			if row[ship.size - 1].length > 0
				@game.stash.clickRow color, "trade_stash", () =>
					trade(system, ship, row)

					@game.stash.unclickRows("trade_stash")


class MoveActions extends Actions

	# Enables selecting a ship to move
	setShipsMoveable = (system) ->
		ships = system.ships[@player.active.id]

		for ship in ships
			ship.click "move_ship", () =>
				setSystemsVisitable(system, ship)
				setStashDiscoverable(system, ship)

				ship.unclick("move_ship") for ship in ships

	# Set travel rule applied systems selectable for visiting
	setSystemsVisitable = (system, ship) ->
		systems = @game.systems.filter (sys) ->
			sys.stars.filter( (st) -> st in system.stars).length == 0

		for tsystem in systems
			tsystem.click "move_system", () =>
				move(system, ship, tsystem)

				system.unclick("move_system") for system in systems
				@game.stash.unclickCells("discover_stash")

	# Set stash cell for star creation
	setStashDiscoverable = (system, ship) ->
		for color, row of @game.stash.stack
			for size in [1..3]
				if size not in (st.size for st in system.stars)
					@game.stash.clickCell color, size, "discover_stash" () =>
						setNewSystemDiscoverable(system, ship, row[size - 1])

						@game.stash.unclickCells("discover_stash")
						system.unclick("move_system") for system in @game.systems

	# Make game accept click for new system creation
	setNewSystemDiscoverable = (system, ship, scell) ->
		game = @game
		game.click "discover_newsystem", (event) ->
			if $(event.target).attr("id") == "game"
				x = event.pageX - $(@).offset().left
				y = event.pageY - $(@).offset().top
				discover(system, ship, scell, [x, y])

				game.unclick("discover_newsystem")
