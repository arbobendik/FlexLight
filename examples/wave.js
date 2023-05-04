"use strict";
// Declare engine global.
var engine;
// Start scene buider
buildScene();
// Build example scene
async function buildScene() {
	// Create new canvas.
	var canvas = document.createElement("canvas");
	// Append it to body.
	document.body.appendChild(canvas);
	engine = new FlexLight(canvas);
	engine.io = 'web';

	let camera = engine.camera;
	let scene = engine.scene;
	// Create pbr textures.
	let normal_tex = await scene.textureFromRME([0.1, 0.5, 0], 1, 1);
	let cuboid_tex = await scene.textureFromRME([0.2, 0.3, 0.02], 1, 1);
	scene.pbrTextures.push(normal_tex, cuboid_tex);
	// Generate translucency texture for cube.
	let translucencyTex = await scene.textureFromTPO([0, 0, 1.3 / 4], 1, 1);
	scene.translucencyTextures.push(translucencyTex);
	// Set light source.
	scene.primaryLightSources = [[0, 10, 0]];
	// Modify brightness.
	scene.primaryLightSources[0].intensity = 200;
	// Generate plane.
	let this_plane = scene.Plane([-100,-1,-100], [100,-1,-100], [100,-1,100], [-100,-1,100]);
  	this_plane.textureNums = [-1, 0, -1];
	// Push both objects to render queue.
	scene.queue.push(this_plane);
	// Set power of 2 square length.
	let power = 3;
	let sideLength = 2 ** power;
	// Set camera perspective and position.
	[camera.x, camera.y, camera.z] = [4 + sideLength, 3 + power, 4 + sideLength];
	[camera.fx, camera.fy] = [0.75 * Math.PI, 0.6];
	// Colors.
	let colors = [];
	// assign each pillar a color.
	for (let i = 0; i < sideLength; i++) {
		let row = [];
		for (let j = 0; j < sideLength; j++) row.push([Math.random(), Math.random(), Math.random()].map(item => item * 255));
		colors.push(row);
	}

	// Declare recursive function to build recursive structure for maximal bounding box performance increase.
	var drawMap = (pot, x, y, notSquare) => {
		// Base case.
		if (pot === 0) {
			let cuboid = scene.Cuboid(x, x + 1 , -1, 0.1 + Math.sin(t + x * 0.5 + y), y, y + 1);
			// Set PBR properties and colors for blocks.
      		cuboid.textureNums = [-1, 1, 0];
      		cuboid.color = colors[x][y];
			return cuboid;
		}
		// Decide to split vertically or horizontally.
		if (notSquare) {
			// Get side length of next smaller square.
			let sideLength = 2 ** ((pot - 1) * 0.5);
			// Create object.
			return [
				drawMap(pot - 1, x, y, false),
				drawMap(pot - 1, x, y + sideLength, false)
			];
		} else {
			let sideLength = 2 ** (pot * 0.5);
			return [
				drawMap(pot - 1, x, y, true),
				drawMap(pot - 1, x + sideLength * 0.5, y, true)
			];
		}
	};

	// Init iterator variable for simple animations.
	let t = 0;
	setInterval(() => {
		// Increase iterator.
		t += 0.02;
		// Package cuboids together in a shared bounding volume.
		let test = drawMap(2 * power, 0, 0, false);
		engine.scene.queue[1] = test;
		engine.scene.updateBoundings();
	}, 100 / 6);

	// Start render engine.
	engine.renderer.render();
	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
	setInterval(() => {
		fpsCounter.textContent = engine.renderer.fps;
	}, 100);
}
