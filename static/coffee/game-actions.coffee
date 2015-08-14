#!/usr/bin/env coffee


# Star system radius
sysradius = 50


class BaseActions

	# Bind game and players to instance
	constructor: (@game) ->
		@players = {
			active: @game.getActivePlayer(),
			inactive: @game.getInactivePlayer()
		}


class Actions extends BaseActions

	# Configure actions
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
	setSystemsSelectable: () =>
		systems = @game.systems
		for system in systems
			do (system) =>

				system.click "select", () =>
					@setActionsSelectable(system)
					system.unclick("select") for system in systems

	# Set all stars and own ships in a system selectable
	setActionsSelectable: (system) =>
		pieces = [system.stars..., system.ships[@players.active.id]...]
		for piece in pieces
			do (piece) =>

				piece.click "action", () =>
					@getAction(piece)(system)
					piece.unclick("action") for piece in pieces

	# Get piece action depending on color
	getAction: (piece) =>
		switch piece.color
			when "red" then @actions.attack.setShipsCaptureable
			when "green" then @actions.build.setStashBuildable
			when "blue" then @actions.trade.setShipsTradable
			when "yellow" then @actions.move.setShipsMoveable


class AttackActions extends BaseActions

	# Set all ships in the same system attackable
	setShipsCaptureable: (system) =>
		ships = system.ships[@players.inactive.id].filter (s) ->
			s.size <= Math.max.apply(null, (sh.size for sh in system.ships[@players.active.id]))

		for ship in ships
			do (ship) =>

				ship.click "attack", () =>
					@attack(system, ship)
					ship.unclick("attack") for ship in ships

	attack: (system, ship) =>


class BuildActions extends BaseActions

	# Set stash rows with matching colors in the current system selectable
	setStashBuildable: (system) =>
		stash = @game.stash
		colors = (ship.color for ship in system.ships[@players.active.id])

		for color, row of stash.stack
			if color in colors
				cell = row.filter( (r) -> r.length > 0 )[0]
				if cell
					do (color, cell) =>

						stash.click color, cell[0].size, "build", () =>
							@build(system, cell)
							stash.unclick("build")

	build: (system, pieces) =>


class TradeActions extends BaseActions

	# Make own ships tradable
	setShipsTradable: (system) =>
		ships = system.ships[@players.active.id]
		for ship in ships
			do (ship) =>

				ship.click "trade_ship", () =>
					@setStashTradable(system, ship)
					ship.unclick("trade_ship") for ship in ships

	# Set stash rows clickable for trading
	setStashTradable: (system, ship) =>
		stash = @game.stash
		for color, row of stash.stack
			cell = row[ship.size - 1]
			if cell.length > 0
				do (color, cell) =>

					stash.click color, cell[0].size, "trade_stash", () =>
						@trade(system, ship, cell)
						stash.unclick("trade_stash")

	trade: (system, ship, pieces) =>


class MoveActions extends BaseActions

	# Enables selecting a ship to move
	setShipsMoveable: (system) =>
		ships = system.ships[@players.active.id]
		for ship in ships
			do (ship) =>

				ship.click "move_ship", () =>
					@setSystemsVisitable(system, ship)
					@setStashDiscoverable(system, ship)
					ship.unclick("move_ship") for ship in ships

	# Set travel rule applied systems selectable for visiting
	setSystemsVisitable: (system, ship) =>
		stash = @game.stash
		systems = @game.systems.filter (sys) ->
			sys.stars.filter( (st) -> st.size in (st2.size for st2 in system.stars) ).length == 0

		for tsystem in systems
			do (tsystem) =>

				tsystem.click "move_system", () =>
					@move(system, ship, tsystem)
					system.unclick("move_system") for system in systems
					stash.unclick("discover_stash")

	# Set stash cell for star creation
	setStashDiscoverable: (system, ship) =>
		[systems, stash] = [@game.systems, @game.stash]
		for color, row of stash.stack
			for size in [1..3]
				if size not in (st.size for st in system.stars) and row[size - 1].length > 0
					do (color, row, size) =>

						stash.click color, size, "discover_stash", () =>
							@setNewSystemDiscoverable(system, ship, row[size - 1])
							stash.unclick("discover_stash")
							system.unclick("move_system") for system in systems

	# Make game accept click for new system creation
	setNewSystemDiscoverable: (system, ship, pieces) =>
		@game.click "discover_newsystem", (event) =>
			if $(event.target).attr("id") in ["game", "surface"]
				x = event.pageX - @game.e.offset().left
				y = event.pageY - @game.e.offset().top
				@discover(system, ship, pieces, [x, y])
				@game.unclick("discover_newsystem")

	discover: (system, ship, pieces, pos) =>

	move: (system, ship, nextsys) =>
