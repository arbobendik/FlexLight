'use strict';

// Generate a new io object
export class WebIo {
	static #translationMap = {
		right: -1,
		left: 1,
		down: -2,
		up: 2,
		backward: -3,
		forward: 3
	};

	#isListening = false;
	#savedTime;

  	#keyMap = {};
	#pressedKeys = {};
	#movement = [0, 0, 0];
	// movement sensitivity
	mouseX = 4;
	mouseY = 2;
	movementSpeed = 0.01;

	camera;

	constructor (canvas, camera) {
		this.registerKey('KeyW', 'forward');
		this.registerKey('KeyA', 'left');
		this.registerKey('KeyS', 'backward');
		this.registerKey('KeyD', 'right');
		this.registerKey('Space', 'up');
		this.registerKey('ShiftLeft', 'down');
		this.camera = camera;
		this.setupForCanvas(canvas);
		requestAnimationFrame(this.frame);
	}

	registerKey = (key, value) => {
		this.#keyMap[key] = WebIo.#translationMap[value];
		this.#pressedKeys[key] = false;
	}

	frame = () => {
		this.update(performance.now());
		requestAnimationFrame(this.frame);
	}

	update = (time) => {
		if (!this.#isListening) return;
			const c = this.camera;
			const difference = (time - this.#savedTime) * this.movementSpeed;
			c.x += difference * (this.#movement[0] * Math.cos(c.fx) + this.#movement[2] * Math.sin(c.fx));
			c.y += difference * this.#movement[1];
			c.z += difference * (this.#movement[2] * Math.cos(c.fx) - this.#movement[0] * Math.sin(c.fx));
			this.#savedTime = time;
	}

	resetMovement = () => {
		for (const key in this.#pressedKeys) this.#pressedKeys[key] = false;
	}

	updateMovement = (value) => {
		this.#movement[Math.abs(value) - 1] += Math.sign(value);
	}

	setupForCanvas = (canvas) => {
		const io = this;

		canvas.tabIndex = 0;
		canvas.onfocus = () => {
			canvas.requestPointerLock();
		};

		document.onpointerlockchange = (event) => {
			io.#isListening = !io.#isListening;
			if (io.#isListening) io.#savedTime = event.timeStamp;
			else {
				io.resetMovement();
				canvas.blur();
			}
		};

		canvas.onkeydown = (event) => {
			if (event.code in io.#pressedKeys) {
				if (io.#pressedKeys[event.code]) return;
				io.update(event.timeStamp);
				io.#pressedKeys[event.code] = true;
				io.updateMovement(io.#keyMap[event.code]);
			}
		};

		canvas.onkeyup = (event) => {
			if (event.code in io.#pressedKeys && io.#pressedKeys[event.code]) {
				io.update(event.timeStamp);
				io.#pressedKeys[event.code] = false;
				io.updateMovement(- io.#keyMap[event.code]);
			}
		};

		canvas.onmousemove = (event) => {
			if (!io.#isListening) return;
			const speed = [io.mouseX / canvas.width, io.mouseY / canvas.height];
			var movement = [speed[0] * event.movementX, speed[1] * event.movementY];
			io.camera.fx -= movement[0];
			if (2 * Math.abs(io.camera.fy + movement[1]) < Math.PI) io.camera.fy += movement[1];
		};
	}
}
