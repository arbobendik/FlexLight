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

	[
		"textures/grass.jpg",     // 0
	].forEach((item, i) => {
		let img = new Image();
	  	img.src = item;
	  	scene.textures.push(img);
	});

	// Create pbr textures.
	let normalTex = await scene.textureFromRME([1, 0, 0], 1, 1);
	let clearTex = await scene.textureFromRME([0, 0.5, 0], 1, 1);
	scene.pbrTextures.push(normalTex, clearTex);

	let translucencyTex = await scene.textureFromTPO([1, 0, 2.42 / 4], 1, 1);
	scene.translucencyTextures.push(translucencyTex); // 0

	// Set camera perspective and position.
	[camera.x, camera.y, camera.z] = [0, 3, 0];
	[camera.fx, camera.fy] = [- 2.38, 0.2];

	// Generate plane.
	let plane = scene.Plane([- 50, - 1, - 50], [50, - 1, - 50], [50, - 1, 50], [- 50, - 1, 50], [0, 1, 0]);
	plane.textureNums = [- 1, 0, - 1];

	scene.primaryLightSources = [[40, 50, 40]];
	scene.primaryLightSources[0].intensity = 500;

	scene.ambientLight = [0.1, 0.1, 0.1];
	
	scene.queue.push(plane);

	// Start render engine.
	engine.renderer.render();

	
	
	/*
	let obj = await scene.fetchObjFile('objects/monke.obj');
	// obj.scale(5);
	obj.move(10, 0, - 10);
	scene.queue.push(obj);
	*/

	/*
	let grass = await scene.fetchObjFile('objects/erde.obj');
	grass.move(8, -2, 8)
	grass.scale(2);
	grass.textureNums = [0, - 1, - 1];
	scene.queue.push(grass);
	*/
	
	
	let monkeyBound = [];
	for (let i = 0; i < 3; i++) {
		let obj = await scene.fetchObjFile('objects/monke.obj');
		obj.scale(i * 0.2 + 1);
		obj.move(10 + 2.5 * i , 0.5, - 11 - 1.3 * i);
		obj.textureNums = [-1, 1, 0]
		let color = [180, 180, 180];
		color[i] += 70;
		obj.color = color;
		monkeyBound.push(obj);
	}
	scene.queue.push(scene.Bounding(monkeyBound));
	


	// Add FPS counter to top-right corner
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
  	// Update Counter periodically.
	setInterval(() => {
		fpsCounter.textContent = engine.renderer.fps;
		// Update texture atlases.
		// engine.renderer.updateBuffers();
	}, 100);
}
