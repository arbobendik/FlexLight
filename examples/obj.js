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
	let normalTex = await scene.textureFromRME([0.3, 0, 0], 1, 1);
	let clearTex = await scene.textureFromRME([0, 0, 0], 1, 1);
	scene.pbrTextures.push(normalTex, clearTex);

	let waterTex = await scene.textureFromTPO([1, 0.5, 1.3 / 4], 1, 1);
	scene.translucencyTextures.push(waterTex);

	// Set camera perspective and position.
	[camera.x, camera.y, camera.z] = [-5, 2, -5];
	[camera.fx, camera.fy] = [0.870, 0.235];

	// Generate plane.
	let waterCuboid = scene.Cuboid(-20, 20, -10, -1, -20, 20);
	let plane = scene.Plane([-50,-1,-50],[50,-1,-50],[50,-1,50],[-50,-1,50],[0,1,0]);
	waterCuboid.setTextureNums(-1, 1, 0);
	waterCuboid.setColor(150, 210, 255);

	let monke = await scene.fetchObjFile('objects/sphere_tri.obj');
	monke.move(0, 0, 0);

	// let cube = await scene.Cuboid(-2, 2, -10, 2, -2, 2);

	scene.primaryLightSources = [[40, 50, 40]];
	scene.primaryLightSources[0].intensity = 5000;
	scene.ambientLight = [0.1, 0.1, 0.1];
	
	scene.queue.push(plane, monke);
	// Start render engine.
	engine.renderer.render();

	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
  	// Update Counter periodically.
	setInterval(() => {
		fpsCounter.textContent = engine.renderer.fps;
		// Update texture atlases.
		engine.renderer.updatePbrTextures();
		engine.renderer.updateTranslucencyTextures();
	}, 1000);
}
