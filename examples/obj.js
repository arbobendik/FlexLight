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
	].forEach(item => {
		let img = new Image();
	  	img.src = item;
	  	scene.textures.push(img);
	});

	// Set camera perspective and position.
	[camera.x, camera.y, camera.z] = [0, 10, 0];
	[camera.fx, camera.fy] = [-2.38, 0.8];
	
	
	scene.primaryLightSources = [[100, 500, 100], [-100, 100, 500]];
	scene.primaryLightSources[0].intensity = 2000000;
	scene.primaryLightSources[0].variation = 100;
	scene.primaryLightSources[1].intensity = 1500000;
	scene.primaryLightSources[1].variation = 100;
	
	
	scene.ambientLight = [.01, .01, .01];
	
	// scene.queue.push(plane);

	// Start render engine.
	engine.renderer.render();

	// const search = new URLSearchParams(location.search);
	let urlParams = new URL(document.location).searchParams;

	// console.log(search.getAll());
	let model = urlParams.get('model') ?? 'sphere';
	console.log('loading ' + model);

	let modelUrl = 'objects/' + model + '.obj';
	let materialUrl = 'objects/' + model + '.mtl';
	var mtl = await scene.importMtl(materialUrl);
	var obj = await scene.importObj(modelUrl, mtl);
	// obj.emissiveness = 0;
	// obj.scale(5);
	obj.move(5, 0, - 5);
	/*
	obj.roughness = .1;
	console.log(obj);
	obj.metallicity = 0.1;
	obj.translucency = 0.9;
	obj.ior = 9.5;
	obj.color = [255, 200, 90];
	*/
	scene.queue.push(obj);
	engine.renderer.updateScene();

	// Add FPS counter to top-right corner
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// setTimeout(() => engine.renderer.freeze = true, 1000);
	
	/*
	// init iterator variable for simple animations
	let iterator = 0;

	setInterval(() => {
		// increase iterator
		iterator += 0.01;
		// precalculate sin and cos
		let [sin, cos] = [Math.sin(iterator), Math.cos(iterator)];
		// animate light sources
		scene.primaryLightSources[0] = [50*sin, 50, 50*cos];
		scene.primaryLightSources[0].variation = 10;
		scene.primaryLightSources[0].intensity = 10000;
		engine.renderer.updatePrimaryLightSources();
	}, 100/6);
	*/
	// Update Counter periodically.
	setInterval(() => {
		fpsCounter.textContent = engine.renderer.fps;
	}, 1000);
}
