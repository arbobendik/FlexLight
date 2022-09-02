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
	let normal_tex = await scene.textureFromRME([0.3, 0, 0], 1, 1);
	scene.pbrTextures.push(normal_tex);

	// Set camera perspective and position.
	[camera.x, camera.y, camera.z] = [-5, 2, -5];
	[camera.fx, camera.fy] = [0.870, 0.235];

	// Generate plane.
	let this_plane = scene.Plane([-100,-1,-100],[100,-1,-100],[100,-1,100],[-100,-1,100],[0,1,0]);
	this_plane.setTextureNums(-1, 0, -1);

	let monke = await scene.fetchObjFile('objects/monke.obj');

	scene.primaryLightSources = [[20, 10, 20]];
	scene.ambientLight = [0.1, 0.1, 0.1];
	
	scene.queue.push(this_plane, monke);
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
