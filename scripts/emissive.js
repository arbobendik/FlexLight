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
	let roughTex = await scene.textureFromRME([1, 0, 0], 1, 1);
	let roughLight = await scene.textureFromRME([1, 0, 0.1], 1, 1);
  let smoothTex = await scene.textureFromRME([0, 0, 0], 1, 1);
  let caroTex = await scene.textureFromRME(
		[
			Array(64).fill([
				Array(64).fill([1, 0, 0.5]).flat(),
				Array(64).fill([0.1, 1, 0]).flat()
			].flat()).flat(),
			Array(64).fill([
				Array(64).fill([0.1, 1, 0]).flat(),
				Array(64).fill([1, 0, 0.5]).flat()
			].flat()).flat()
		].flat(),
	128, 128);
	scene.pbrTextures.push(roughTex, caroTex, roughLight, smoothTex);

  // Generate translucency texture for cube.
  let translucencyTex = await scene.textureFromTPO([1, 0, 1.3 / 4], 1, 1);
  scene.translucencyTextures.push(translucencyTex);

  // Move camera out of center.
  camera.z = -20;

	// Remove primary light source in favour of emissive.
	scene.primaryLightSources = [];
	// Generate side planes of box.
	let bottom_plane = scene.Plane([-5,-5,-15],[5,-5,-15],[5,-5,5],[-5,-5,5]);
	let top_plane = scene.Plane([-5,5,-15],[-5,5,5],[5,5,5],[5,5,-15]);
	let back_plane = scene.Plane([-5,-5,5],[5,-5,5],[5,5,5],[-5,5,5]);
	let front_plane = scene.Plane([-5,-5,-15],[-5,5,-15],[5,5,-15],[5,-5,-15]);
	let left_plane = scene.Plane([-5,-5,-15],[-5,-5,5],[-5,5,5],[-5,5,-15]);
	let right_plane = scene.Plane([5,-5,-15],[5,5,-15],[5,5,5],[5,-5,5]);
  // Make planes diffuse.
  [bottom_plane, top_plane, back_plane, front_plane].forEach((item) => item.setTextureNums(-1, 0, -1));
  [left_plane, right_plane].forEach((item) => item.setTextureNums(-1, 2, -1));
  // Color left and right plane.
  left_plane.setColor(255, 0, 0);
  right_plane.setColor(0, 255, 0);
	// Generate a few cuboids in the box with respective bounding box.
	let r = [[], []];
	r[0] = scene.Cuboid(-3, -1.5, -5, -2, -1, 1);
	// Generate rotated cube object from planes.
	var [x, x2, y, y2, z, z2] = [0, 3, -5, -1, -1, 2];
	var [b0, b1, b2, b3] = [[x+1,  y, z], [x2,  y, z+1], [x2-1,  y, z2], [x,  y, z2-1]]
	var [t0, t1, t2, t3] = [[x+1, y2, z], [x2, y2, z+1], [x2-1, y2, z2], [x, y2, z2-1]]
  r[1] = scene.Cuboid(x, x2, y, y2, z, z2);
  r[1][1] = scene.Plane(t0,t1,t2,t3,[0,1,0]);
  r[1][2] = scene.Plane(t1,b1,b2,t2,[1,0,0]);
  r[1][3] = scene.Plane(t2,b2,b3,t3,[0,0,1]);
  r[1][4] = scene.Plane(b3,b2,b1,b0,[0,-1,0]);
  r[1][5] = scene.Plane(t3,b3,b0,t0,[-1,0,0]);
  r[1][6] = scene.Plane(t0,b0,b1,t1,[0,0,-1]);

  r[0].setTextureNums(-1, 1, -1);
	// Make second cuboid smooth.
	r[1].setTextureNums(-1, 3, 0);
	// Package cube and cuboids together in a shared bounding volume.
	let objects = [
    [-3, 3, -5, 0, -3, 3],
    r[0], r[1]
	];

	let box = [
		[-5, 5, -5, 5, -15, 5],
		bottom_plane, top_plane, back_plane, front_plane, left_plane, right_plane
	];
	// Push both objects to render queue.
	scene.queue.push(objects, box);
	// Start render engine.
	engine.renderer.render();

	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
  setInterval(function(){
		fpsCounter.textContent = engine.renderer.fps;
		// Update textures every second
		engine.renderer.updateTextures();
    engine.renderer.updatePbrTextures();
    engine.renderer.updateTranslucencyTextures();
	},1000);
}
