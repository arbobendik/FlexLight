"use strict";
/**
	@setup
	var playerHandler = new PlayerHandler();
	playerHandler.KEYMAP
		.registerKey()

KEYMAP: [["w", 0, 0, 1], ["s", 0, 0, -1], ["a", 1, 0, 0], ["d", -1, 0, 0], [" ", 0, 1, 0], ["shift", 0, -1, 0]],
**/

PlayerHandler.KeyMap = function() {}

Object.assign(PlayerHandler.KeyMap, {
	RIGHT: -1,
	LEFT: 1,
	DOWN: -2,
	UP: 2,
	BACKWARD: -3,
	FORWARD: 3,
	MOUSE_X: 1 / 500,
	MOUSE_Y: 1 / 500,
	MOVEMENT_SPEED: 0.01
});

PlayerHandler.KeyMap.prototype.registerKey = function(key, value) {
	this[key] = PlayerMovementHandler.KeyMap[value];
	return this;
}

PlayerHandler.prototype.update = function(time) {
	if (this.isListening) {
		const r = this.targetRenderer;
		const difference = time - this.savedTime * this.KeyMap.MOVEMENT_SPEED;
		r.x += difference * (this.movement[0] * Math.cos(r.fx) + this.movement[2] * Math.sin(r.fx));
		r.y += difference * this.movement[1];
		r.z += difference * (this.movement[2] * Math.cos(r.fx) - this.movement[0] * Math.sin(r.fx));
		this.savedTime = time;
	}
}

/*
if (RT.MOVEMENT){
	let deltaTime = (window.performance.now() - Millis) * RT.MOVEMENT_SPEED;
	RT.X += (DeltaX * Math.cos(RT.FX) + DeltaZ * Math.sin(RT.FX)) * deltaTime;
	RT.Y += DeltaY * deltaTime;
	RT.Z += (DeltaZ * Math.cos(RT.FX) - DeltaX * Math.sin(RT.FX)) * deltaTime;
}
*/


PlayerHandler.prototype.updateMovement = function(value) {
	this.movement[Math.abs(value) - 1] += Math.sign(value);
}

PlayerHandler.prototype.resetMovement = function() {
	this.movement = [0, 0, 0];
}

PlayerHandler.prototype.setupForCanvas(canvas) {
	const handler = this;

	canvas.tabIndex = 0;
	canvas.addEventListener("focus", function(event) {
		handler.savedTime = event.timeStamp;
		handler.isListening = true;
	});

	canvas.addEventListener("keydown", function(event) {
		if (event.repeat) return;

		if (event.code in handler.KEYMAP) {
			handler.updateMovement(handler.KEYMAP[event.code]);
		}
	});

	canvas.addEventListener("keyup", function(event) {
		if (event.code in handler.KEYMAP) {
			handler.update(event.timeStamp);
			handler.updateMovement(-handler.KEYMAP[event.code]);
		}
	});

	canvas.addEventListener("mousemove", function(event) {
		var movement = [PlayerHandler.KeyMap.MOUSE_X * event.movementX, PlayerHandler.KeyMap.MOUSE_Y * event.movementY];
		handler.targetRenderer.fx -= movement[0];
		if (2 * Math.abs(targetRenderer.fy + movement[1]) < Math.PI) targetRenderer.fy += movement[1];
	});

	canvas.addEventListener("blur", function() {
		handler.isListening = false;
		handler.resetMovement();
	});
}

function PlayerHandler(targetRenderer) {
	this.KEYMAP = new PlayerHandler.KeyMap();
	this.isListening = false;
	this.targetRenderer = targetRenderer;
	this.setupForCanvas(targetRenderer.canvas);
	this.resetMovement();
}
