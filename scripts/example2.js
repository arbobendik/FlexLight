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
  engine = new FlexLight (canvas);
  engine.io = 'web';

  let camera = engine.camera;
  let scene = engine.scene;
	// Create pbr textures.
	let normal_tex = await scene.textureFromRME([0.5, 0, 0], 1, 1);
	scene.pbrTextures.push(normal_tex);

	// Set camera perspective and position.
	[camera.x, camera.y, camera.z] = [-12, 5, -18];
	[camera.fx, camera.fy] = [0.440, 0.235];

	// Set two light sources.
	scene.primaryLightSources = [[0, 10, 0], [5, 5, 5]];
	scene.primaryLightSources[0].intensity = 100;
	scene.primaryLightSources[1].intensity = 100;

	// Generate plane.
	let this_plane = scene.Plane([-100,-1,-100],[100,-1,-100],[100,-1,100],[-100,-1,100],[0,1,0]);
  this_plane.setTextureNums(-1, 0, -1);
	// Generate a few cuboids on the planes with bounding box.
	let r = [];
	r[0] = scene.Cuboid(-1.5, 4.5, -1, 2, 1.5, 2.5);
	r[1] = scene.Cuboid(-1.5, 1.5, -1, 2, -2, -1);
	r[2] = scene.Cuboid(0.5, 1.5, -1, 2, -1, 0);
	r[3] = scene.Cuboid(-1.5, -0.5, -1, 2, -1, 0);
	// Color all cuboids in center.
	for (let i = 0; i < 4; i++){
    r[i].setColor(Math.random() * 255, Math.random() * 255, Math.random() * 255);
	}

	// Spawn cube.
	let cube = scene.Cuboid(5.5, 6.5, 1.5, 2.5, 5.5, 6.5);
	// Package cube and cuboids together in a shared bounding volume.
	let objects = [
	  [-1.5, 6.5, -1, 2.5, -2, 6.5],
	  [[-1.5, 4.5, -1, 2, -2, 2.5], r[0], r[1], r[2], r[3]],
	  cube
	];
	// Push both objects to render queue.
	scene.queue.push(this_plane, objects);
	// Start render engine.
	engine.renderer.render();

	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
  // Update Counter periodically.
	setInterval(function(){
		fpsCounter.textContent = engine.renderer.fps;
		// Update textures every second.
		engine.renderer.updateTextures();
		engine.renderer.updatePbrTextures();
    engine.renderer.updateTranslucencyTextures();
	},1000);

	// Init iterator variable for simple animations.
	let iterator = 0;

	setInterval(async function(){
		// Increase iterator.
		iterator += 0.01;
		// Precalculate sin and cos.
		let [sin, cos] = [Math.sin(iterator), Math.cos(iterator)];
		// Animate light sources.
		scene.primaryLightSources =  [[20*sin, 8, 20*cos], [2*cos, 80, 10*sin]];
    scene.primaryLightSources[0].intensity = 100;
		scene.primaryLightSources[1].intensity = 800;
		engine.renderer.updatePrimaryLightSources();
		// Calculate new width for this frame.
		let newX = 6.5 + 4 * sin;
		// Create new resized R0 object.
		let newR0 = scene.Cuboid(-1.5 + newX, 1.5 + newX, -1, 2, 1.5, 2.5);
		// Color new cuboid.
		for (let j = 1; j < 7; j++) newR0[j].colors = r[0][j].colors;
		// Update bounding boxes.
		scene.queue[1][0] = [-1.5, 6.5 + newX, -1, 2.5, -2, 6.5];
		scene.queue[1][1][0] = [-1.5, 4.5 + newX, -1, 2, -2, 2.5];
		// Push element in QUEUE.
		scene.queue[1][1][1] = newR0;
	}, 100/6);
}
