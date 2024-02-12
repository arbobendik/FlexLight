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

	// Set camera perspective and position.
	[camera.x, camera.y, camera.z] = [0, 3, 0];
	[camera.fx, camera.fy] = [- Math.PI / 4, 0.1];

	scene.primaryLightSources = [[50, 70, 50]];
	scene.primaryLightSources[0].intensity = 40000;
	scene.ambientLight = [0.1, 0.1, 0.1];

	// Generate plane.
	let plane = scene.Plane([- 50, - 1, - 50], [50, - 1, - 50], [50, - 1, 50], [- 50, - 1, 50], [0, 1, 0]);
	plane.roughness = .8;
	plane.metallicity = .7;
	scene.queue.push(plane);

	// Start render engine.
	engine.renderer.render();

	var obj = await scene.importObj('objects/dragon_lp.obj');
	obj.scale(0.5);
	await obj.move(15, 0, 15);
	// obj.textureNums = [-1, 1, 0];
	obj.roughness = 0;
	obj.metallicity = 1;
	obj.translucency = 1;
	obj.ior = 1.5;
	obj.color = [255, 100, 100];
	// obj.staticPermanent = true;
	scene.queue.push(obj);
	
	var monke = await scene.importObj('objects/monke.obj');
	monke.scale(2);
	await monke.move(5, 1, 12);
	monke.metallicity = 1;
	scene.queue.push(monke);

	var sphere = await scene.importObj('objects/sphere.obj');
	sphere.scale(4);
	await sphere.move(15, 3, 0);
	sphere.metallicity = 1;
	sphere.roughness = 0;
	sphere.translucency = 1;
	sphere.ior = 1.3;
	scene.queue.push(sphere);

	/*
	var sphere2 = await scene.importObj('objects/sphere.obj');
	sphere2.scale(3);
	await sphere2.move(15, 3, -15);
	sphere2.metallicity = 1;
	sphere2.translucency = 1;
	scene.queue.push(sphere2);
	*/
	// Add FPS counter to top-right corner
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// setTimeout(() => engine.renderer.freeze = true, 1000);
	
	// Update Counter periodically.
	setInterval(() => {
		fpsCounter.textContent = engine.renderer.fps;
	}, 1000);
}
