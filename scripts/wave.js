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
	let cuboid_tex = await scene.textureFromRME([0.2, 0.3, 0], 1, 1);
	scene.pbrTextures.push(normal_tex, cuboid_tex);
	// Set light source.
	scene.primaryLightSources = [[0, 10, 0]];
	// Modify brightness.
  scene.primaryLightSources[0].intensity = 150;
  scene.ambient = [0.1, 0.1, 0.1];
	// Generate plane.
	let this_plane = scene.Plane([-100,-1,-100],[100,-1,-100],[100,-1,100],[-100,-1,100],[0,1,0]);
  this_plane.setTextureNums(-1, 0, -1);
	// Push both objects to render queue.
	scene.queue.push(this_plane);
	// Start render engine.
	engine.renderer.render();
	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
	setInterval(function(){
		fpsCounter.textContent = engine.renderer.fps;
		// Update texture atlases.
		engine.renderer.updatePbrTextures();
	},1000);

	// Set power of 2 square length.
	let power = 2;
	let sideLength = 2 ** power;
	// Set camera perspective and position.
	[camera.x, camera.y, camera.z] = [-4 - sideLength, 3 + power, -4];
	[camera.fx, camera.fy] = [0.25 * Math.PI, 0.6];
	// Colors.
	let colors = [];
	// assign each pillar a color.
	for (let i = 0; i < sideLength; i++){
		let row = [];
		for (let j = 0; j < sideLength; j++) row.push([Math.random() * 255, Math.random() * 255, Math.random() * 255]);
		colors.push(row);
	}

	// Declare recursive function to build recursive structure for maximal bounding box performance increase.
	var drawMap = (pot, x, y, notSquare) => {
		// Base case.
		if (pot === 0){
			let cuboid = scene.Cuboid(x, x + 1 , -1, 0.1 + Math.sin(t + x * 0.5 + y), y, y + 1);
			// Set PBR properties and colors for blocks.
      cuboid.setTextureNums(-1, 1, -1);
      cuboid.setColor(colors[x][y]);
			return cuboid;
		}
		// Decide to split vertically or horizontally.
		if (notSquare){
			// Get side length of next smaller square.
			let sideLength = (2 ** (pot - 1)) ** 0.5;
			// Create object.
			return [
				[x, x + sideLength, -1, 1.1, y, y + 2 * sideLength],
				drawMap(pot - 1, x, y, false),
				drawMap(pot - 1, x, y + sideLength, false)
			];
		}else{
			let sideLength = (2 ** pot) ** 0.5;
			return [
				[x, x + sideLength, -1, 1.1, y, y + sideLength],
				drawMap(pot - 1, x, y, true),
				drawMap(pot - 1, x + sideLength * 0.5, y, true)
			];
		}
	};

	// Init iterator variable for simple animations.
	let t = 0;

	setInterval(function(){
		// Increase iterator.
		t += 0.02;
		// Package cuboids together in a shared bounding volume.
		scene.queue[1] = drawMap(2 * power, 0, 0, false);
	}, 100/6);
}
