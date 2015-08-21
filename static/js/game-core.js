// Generated by CoffeeScript 1.9.3
var Element, Game, Player, Ship, Star, Stash, Stashable, Stashed, System, sysradius,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

sysradius = 50;

Player = (function() {
  function Player(current) {
    this.id = current.id;
    this.name = current.name;
    this.actions = current.actions;
  }

  Player.prototype.isActive = function() {
    return this.actions !== 0;
  };

  return Player;

})();

Element = (function() {
  function Element(e) {
    this.e = $(e);
  }

  Element.prototype.render = function(surface) {
    return surface.append(this.e);
  };

  Element.prototype.click = function(key, handler, e) {
    if (e == null) {
      e = this.e;
    }
    e.on("click." + key, function(event) {
      e.addClass("selected");
      return handler(event);
    });
    if (!e.hasClass("selectable")) {
      return e.addClass("selectable");
    } else {
      return this.overload = true;
    }
  };

  Element.prototype.unclick = function(key, e) {
    if (e == null) {
      e = this.e;
    }
    e.off("click." + key);
    if (!this.overload) {
      return e.removeClass("selectable");
    } else {
      return this.overload = false;
    }
  };

  Element.prototype.remove = function() {
    return this.e.detach();
  };

  return Element;

})();

Stash = (function(superClass) {
  extend(Stash, superClass);

  function Stash(current) {
    var i, s;
    this.stack = {
      red: (function() {
        var j, results;
        results = [];
        for (i = j = 0; j <= 2; i = ++j) {
          results.push((function() {
            var k, len, ref, results1;
            ref = current.red[i];
            results1 = [];
            for (k = 0, len = ref.length; k < len; k++) {
              s = ref[k];
              results1.push(new Stashed(s));
            }
            return results1;
          })());
        }
        return results;
      })(),
      green: (function() {
        var j, results;
        results = [];
        for (i = j = 0; j <= 2; i = ++j) {
          results.push((function() {
            var k, len, ref, results1;
            ref = current.green[i];
            results1 = [];
            for (k = 0, len = ref.length; k < len; k++) {
              s = ref[k];
              results1.push(new Stashed(s));
            }
            return results1;
          })());
        }
        return results;
      })(),
      blue: (function() {
        var j, results;
        results = [];
        for (i = j = 0; j <= 2; i = ++j) {
          results.push((function() {
            var k, len, ref, results1;
            ref = current.blue[i];
            results1 = [];
            for (k = 0, len = ref.length; k < len; k++) {
              s = ref[k];
              results1.push(new Stashed(s));
            }
            return results1;
          })());
        }
        return results;
      })(),
      yellow: (function() {
        var j, results;
        results = [];
        for (i = j = 0; j <= 2; i = ++j) {
          results.push((function() {
            var k, len, ref, results1;
            ref = current.yellow[i];
            results1 = [];
            for (k = 0, len = ref.length; k < len; k++) {
              s = ref[k];
              results1.push(new Stashed(s));
            }
            return results1;
          })());
        }
        return results;
      })()
    };
    Stash.__super__.constructor.call(this, "<div id=\"stash-wrapper\">\n	<table id=\"stash\">\n	</table>\n</div>");
  }

  Stash.prototype.render = function(surface) {
    var color, j, k, len, piece, pieces, ref, ref1, size, td, tr;
    ref = this.stack;
    for (color in ref) {
      pieces = ref[color];
      tr = $("<tr class=\"stash-" + color + "\"></tr>");
      for (size = j = 1; j <= 3; size = ++j) {
        td = $("<td class=\"stash-" + size + "\"></td>");
        ref1 = pieces[size - 1];
        for (k = 0, len = ref1.length; k < len; k++) {
          piece = ref1[k];
          piece.render(td);
        }
        tr.append(td);
      }
      this.e.find("#stash").append(tr);
    }
    return Stash.__super__.render.call(this, surface);
  };

  Stash.prototype.click = function() {
    var args, color, size;
    color = arguments[0], size = arguments[1], args = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    return Stash.__super__.click.apply(this, slice.call(args).concat([this.e.find("tr.stash-" + color + " > td.stash-" + size)]));
  };

  Stash.prototype.unclick = function() {
    var args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return Stash.__super__.unclick.apply(this, slice.call(args).concat([this.e.find("td")]));
  };

  Stash.prototype.add = function(obj) {
    var stashed;
    stashed = new Stashed(obj);
    this.stack[obj.color][obj.size - 1].push(stashed);
    return stashed.render(this.e.find(".stash-" + stashed.color + " .stash-" + stashed.size));
  };

  Stash.prototype.getShip = function(obj) {
    var stashed;
    stashed = this.stack[obj.color][obj.size - 1].pop();
    stashed.remove();
    return new Ship(stashed);
  };

  Stash.prototype.getStar = function(obj) {
    var stashed;
    stashed = this.stack[obj.color][obj.size - 1].pop();
    stashed.remove();
    return new Star(stashed);
  };

  return Stash;

})(Element);

Stashable = (function(superClass) {
  extend(Stashable, superClass);

  function Stashable(type) {
    Stashable.__super__.constructor.call(this, "<span class=\"" + type + " " + this.color + " size-" + this.size + "\">\n</span>");
  }

  Stashable.prototype.destroy = function() {
    this.remove();
    return game.stash.add(this);
  };

  return Stashable;

})(Element);

Stashed = (function(superClass) {
  extend(Stashed, superClass);

  function Stashed(current) {
    this.color = current.color;
    this.size = current.size;
    Stashed.__super__.constructor.call(this, "stashed");
  }

  return Stashed;

})(Stashable);

Star = (function(superClass) {
  extend(Star, superClass);

  function Star(current) {
    this.color = current.color;
    this.size = current.size;
    Star.__super__.constructor.call(this, "star");
  }

  return Star;

})(Stashable);

Ship = (function(superClass) {
  extend(Ship, superClass);

  function Ship(current) {
    this.color = current.color;
    this.size = current.size;
    Ship.__super__.constructor.call(this, "ship");
  }

  return Ship;

})(Stashable);

System = (function(superClass) {
  extend(System, superClass);

  function System(current) {
    var s;
    this.pos = current.pos;
    this.home = current.home;
    this.stars = (function() {
      var j, len, ref, results;
      ref = current.stars;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        s = ref[j];
        results.push(new Star(s));
      }
      return results;
    })();
    this.ships = {
      1: (function() {
        var j, len, ref, results;
        ref = current.ships[1];
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          s = ref[j];
          results.push(new Ship(s));
        }
        return results;
      })(),
      2: (function() {
        var j, len, ref, results;
        ref = current.ships[2];
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          s = ref[j];
          results.push(new Ship(s));
        }
        return results;
      })()
    };
    System.__super__.constructor.call(this, "<div class=\"system-clear\" style=\"top: " + (this.pos[1] - sysradius * 2) + "px; left: " + (this.pos[0] - sysradius * 2) + "px;\">\n	<div class=\"system " + (this.home ? 'system-home' : void 0) + "\">\n		<div class=\"ships-left\"></div>\n		<div class=\"stars\"></div>\n		<div class=\"ships-right\"></div>\n	</div>\n</div>");
  }

  System.prototype.render = function(surface) {
    var j, k, l, len, len1, len2, ref, ref1, ref2, ship, star;
    ref = this.stars;
    for (j = 0, len = ref.length; j < len; j++) {
      star = ref[j];
      star.render(this.e.find(".stars"));
    }
    ref1 = this.ships[1];
    for (k = 0, len1 = ref1.length; k < len1; k++) {
      ship = ref1[k];
      ship.render(this.e.find(".ships-right"));
    }
    ref2 = this.ships[2];
    for (l = 0, len2 = ref2.length; l < len2; l++) {
      ship = ref2[l];
      ship.render(this.e.find(".ships-left"));
    }
    return System.__super__.render.call(this, surface);
  };

  System.prototype.click = function() {
    var args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return System.__super__.click.apply(this, slice.call(args).concat([this.e.find(".system")]));
  };

  System.prototype.unclick = function() {
    var args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return System.__super__.unclick.apply(this, slice.call(args).concat([this.e.find(".system")]));
  };

  System.prototype.addShip = function(player, ship) {
    this.ships[player.id].push(ship);
    return ship.render(this.e.find([".ships-right", ".ships-left"][player.id - 1]));
  };

  System.prototype.getShip = function(player, ship) {
    var index;
    index = this.ships[player.id].indexOf(ship);
    ship = this.ships[player.id].splice(index, 1)[0];
    if (this.ships[1].length + this.ships[2].length === 0) {
      this.destroy();
    } else {
      ship.remove();
    }
    return ship;
  };

  System.prototype.removeStar = function(star) {
    var index;
    index = this.stars.indexOf(star);
    this.stars.splice(index, 1)[0].destroy();
    if (stars.length === 0) {
      return this.destroy();
    }
  };

  System.prototype.destroy = function() {
    var j, k, l, len, len1, len2, ref, ref1, ref2, results, ship, star;
    this.remove();
    ref = this.stars;
    for (j = 0, len = ref.length; j < len; j++) {
      star = ref[j];
      star.destroy();
    }
    ref1 = this.ships[1];
    for (k = 0, len1 = ref1.length; k < len1; k++) {
      ship = ref1[k];
      ship.destroy();
    }
    ref2 = this.ships[2];
    results = [];
    for (l = 0, len2 = ref2.length; l < len2; l++) {
      ship = ref2[l];
      results.push(ship.destroy());
    }
    return results;
  };

  return System;

})(Element);

Game = (function(superClass) {
  extend(Game, superClass);

  function Game(current) {
    var p, s;
    this.players = (function() {
      var j, len, ref, results;
      ref = current.players;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        p = ref[j];
        results.push(new Player(p));
      }
      return results;
    })();
    this.systems = (function() {
      var j, len, ref, results;
      ref = current.systems;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        s = ref[j];
        results.push(new System(s));
      }
      return results;
    })();
    this.stash = new Stash(current.stash);
    Game.__super__.constructor.call(this, "<div id=\"game\">\n</div>");
  }

  Game.prototype.render = function(surface) {
    var j, len, ref, system;
    ref = this.systems;
    for (j = 0, len = ref.length; j < len; j++) {
      system = ref[j];
      system.render(this.e);
    }
    this.stash.render(this.e);
    return Game.__super__.render.call(this, surface);
  };

  Game.prototype.getActivePlayer = function() {
    return this.players.filter(function(p) {
      return p.isActive();
    }).pop();
  };

  Game.prototype.getInactivePlayer = function() {
    return this.players.filter(function(p) {
      return !p.isActive();
    }).pop();
  };

  Game.prototype.newSystem = function(star, pos) {
    var system;
    system = new System({
      pos: pos,
      stars: [star],
      ships: {
        1: [],
        2: []
      }
    });
    this.systems.push(system);
    system.render(this.e);
    if (graphics) {
      graphics.render(this.e);
    }
    return system;
  };

  Game.prototype.toJson = function() {
    return JSON.stringify(this);
  };

  return Game;

})(Element);
