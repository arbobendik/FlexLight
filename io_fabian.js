"use strict";

WebIo.KeyMap = function() {}

/*	Map directions into coordinates

		the absolute values of the numbers represent the dimensions
		negative numbers mean negative movements in a dimension
*/
Object.assign(WebIo.KeyMap, {
	RIGHT: -1,
	LEFT: 1,
	DOWN: -2,
	UP: 2,
	BACKWARD: -3,
	FORWARD: 3,
	// MOVEMENT SENSITIVITY
	MOUSE_X: 4,
	MOUSE_Y: 2,
	MOVEMENT_SPEED: 0.01
});

// Add handling for events i.e.: PlayerHandlerObject.KEYMAP.registerKey("KeyW", "FORWARD")
WebIo.KeyMap.prototype.registerKey = function(key, value) {
	this[key] = Io.KeyMap[value];
	return this;
}

// Handle frames
WebIo.prototype.frame = function(time) {
	this.update(time);
	requestAnimationFrame(this.frame.bind(this));
}

// Generic movement handler
WebIo.prototype.update = function(time) {
	if (this.isListening) {
		const r = this.targetRenderer;
		const difference = (time - this.savedTime) * Io.KeyMap.MOVEMENT_SPEED;
		r.x += difference * (this.movement[0] * Math.cos(r.fx) + this.movement[2] * Math.sin(r.fx));
		r.y += difference * this.movement[1];
		r.z += difference * (this.movement[2] * Math.cos(r.fx) - this.movement[0] * Math.sin(r.fx));
		this.savedTime = time;
	}
}

// Reset movement and release all keys
WebIo.prototype.resetMovement = function() {
	this.movement = [0, 0, 0];
	for (const key in this.keysPressed) {
		this.keysPressed[key] = false;
	}
}

// Change movement when pressing a key
WebIo.prototype.updateMovement = function(value) {
	this.movement[Math.abs(value) - 1] += Math.sign(value);
}

// Set up Events for a CanvasElement for handling inputs and mouse movements
WebIo.prototype.setupForCanvas = function(canvas) {
	const handler = this;

	canvas.tabIndex = 0;
	canvas.addEventListener("focus", function() {
		this.requestPointerLock();
	});

	document.addEventListener("pointerlockchange", function(event) {
		handler.isListening = !handler.isListening;
		if (handler.isListening) handler.savedTime = event.timeStamp;
		else {
			handler.resetMovement();
			canvas.blur();
		}
	});

	canvas.addEventListener("keydown", function(event) {
		if (event.code in handler.pressedKeys) {
			if (handler.pressedKeys[event.code]) return;
			handler.update(event.timeStamp);
			handler.pressedKeys[event.code] = true;
			handler.updateMovement(handler.KEYMAP[event.code]);
		}
	});

	canvas.addEventListener("keyup", function(event) {
		if (event.code in handler.pressedKeys && handler.pressedKeys[event.code]) {
			handler.update(event.timeStamp);
			handler.pressedKeys[event.code] = false;
			handler.updateMovement(-handler.KEYMAP[event.code]);
		}
	});

	canvas.addEventListener("mousemove", function(event) {
		if (!handler.isListening) return;
		const speed = [Io.KeyMap.MOUSE_X / canvas.width, WebIo.KeyMap.MOUSE_Y / canvas.height];
		var movement = [speed[0] * event.movementX, speed[1] * event.movementY];
		handler.targetRenderer.fx -= movement[0];
		if (2 * Math.abs(handler.targetRenderer.fy + movement[1]) < Math.PI) handler.targetRenderer.fy += movement[1];
	});
}

// Generate a new PlayerHandlerObject
export function WebIo (targetRenderer) {
	this.KEYMAP = new WebIo.KeyMap()
		.registerKey("KeyW", "FORWARD")
		.registerKey("KeyA", "LEFT")
		.registerKey("KeyS", "BACKWARD")
		.registerKey("KeyD", "RIGHT")
		.registerKey("Space", "UP")
		.registerKey("ShiftLeft", "DOWN");
	this.pressedKeys = {
		KeyW: false,
		KeyA: false,
		KeyS: false,
		KeyD: false,
		Space: false,
		ShiftLeft: false
	};
	this.isListening = false;
	this.targetRenderer = targetRenderer;
	this.setupForCanvas(targetRenderer.canvas);
	this.resetMovement();
	requestAnimationFrame(this.frame.bind(this));
}
