// Generated by CoffeeScript 1.9.3
var getAction, setActionsSelectable, setShipsCaptureable, setStashBuildable, setSystemsSelectable;

setSystemsSelectable = function() {
  var i, len, ref, results, system;
  ref = game.systems;
  results = [];
  for (i = 0, len = ref.length; i < len; i++) {
    system = ref[i];
    results.push(system.click(function() {
      var j, len1, ref1, results1;
      setActionsSelectable(system);
      ref1 = game.systems;
      results1 = [];
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        system = ref1[j];
        results1.push(system.unclick());
      }
      return results1;
    }));
  }
  return results;
};

setActionsSelectable = function(system) {
  var i, len, piece, pieces, results;
  pieces = system.stars + system.ships[game.getActivePlayer().id];
  results = [];
  for (i = 0, len = pieces.length; i < len; i++) {
    piece = pieces[i];
    results.push(piece.click(function() {
      var j, len1, results1;
      getAction(piece.color)(system, piece);
      results1 = [];
      for (j = 0, len1 = pieces.length; j < len1; j++) {
        piece = pieces[j];
        results1.push(piece.unclick());
      }
      return results1;
    }));
  }
  return results;
};

getAction = function(color) {
  switch (color) {
    case "red":
      return setShipsCaptureable;
    case "green":
      return setStashBuildable;
    case "blue":
      return setShipsTradable;
    case "yellow":
      return function(s, p) {
        setSystemsVisitable(s, p);
        return setStashStarCreatable(s, p);
      };
  }
};

setShipsCaptureable = function(system, origin) {
  var i, len, results, ship, ships;
  ships = system.ships[game.getInactivePlayer().id].filter(function(s) {
    return s.size <= origin.size;
  });
  results = [];
  for (i = 0, len = ships.length; i < len; i++) {
    ship = ships[i];
    results.push(ship.click(function() {
      var j, len1, results1;
      attack(system, origin, ship);
      results1 = [];
      for (j = 0, len1 = ships.length; j < len1; j++) {
        ship = ships[j];
        results1.push(ship.unclick());
      }
      return results1;
    }));
  }
  return results;
};

setStashBuildable = function(system, origin) {
  var rows;
  return rows = game.stash.stack[origin.color];
};
