"use strict";
// Declare RayTracer global.
var rt;
// Wait until DOM is loaded.
window.addEventListener("load", async function(){
	// Create new canvas.
	var canvas = document.createElement("canvas");
	// Append it to body.
	document.body.appendChild(canvas);
	// Create new RayTracer (rt) for canvas.
	rt = new rayTracer(canvas);
	// Create 2 pbr metallic textures.
	let roughTex = await rt.textureFromRME([1, 0, 0], 1, 1);
	let roughLight = await rt.textureFromRME([1, 0, 0.2], 1, 1);
  let smoothTex = await rt.textureFromRME([0, 0, 0], 1, 1);
  let caroTex = await rt.textureFromRME(
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
	rt.pbrTextures.push(roughTex, caroTex, roughLight, smoothTex);

  // Generate translucency texture for cube.
  let translucencyTex = await rt.textureFromTPO([1, 0, 1.3 / 4], 1, 1);
  rt.translucencyTextures.push(translucencyTex);

  // Move camera out of center.
  rt.Z = -20;

	// Remove primary light source in favour of emissive.
	rt.primaryLightSources = [];
	// Generate side planes of box.
	let bottom_plane = rt.plane([-5,-5,-15],[5,-5,-15],[5,-5,5],[-5,-5,5],[0,1,0]);
	let top_plane = rt.plane([-5,5,-15],[-5,5,5],[5,5,5],[5,5,-15],[0,-1,0]);
	let back_plane = rt.plane([-5,-5,5],[5,-5,5],[5,5,5],[-5,5,5],[0,0,-1]);
	let front_plane = rt.plane([-5,-5,-15],[-5,5,-15],[5,5,-15],[5,-5,-15],[0,0,1]);
	let left_plane = rt.plane([-5,-5,-15],[-5,-5,5],[-5,5,5],[-5,5,-15],[1,0,0]);
	let right_plane = rt.plane([5,-5,-15],[5,5,-15],[5,5,5],[5,-5,5],[-1,0,0]);
  // Make planes diffuse.
	bottom_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
  top_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
	back_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
	front_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
  left_plane.textureNums = new Array(6).fill([-1,2,-1]).flat();
  right_plane.textureNums = new Array(6).fill([-1,2,-1]).flat();
  // Color left and right plane.
  left_plane.colors = new Array(6).fill([1, 0, 0]).flat();
  right_plane.colors = new Array(6).fill([0, 1, 0]).flat();
	// Generate a few cuboids in the box with respective bounding box.
	let r = [[], []];
	r[0] = rt.cuboid(-3, -1.5, -5, -2, -1, 1);
	// Generate rotated cube object from planes.
	var [x, x2, y, y2, z, z2] = [0, 3, -5, -1, -1, 2];
	var [b0, b1, b2, b3] = [[x+1,  y, z], [x2,  y, z+1], [x2-1,  y, z2], [x,  y, z2-1]]
	var [t0, t1, t2, t3] = [[x+1, y2, z], [x2, y2, z+1], [x2-1, y2, z2], [x, y2, z2-1]]
  r[1][0] = [x, x2, y, y2, z, z2];
  r[1][1] = rt.plane(t0,t1,t2,t3,[0,1,0]);
  r[1][2] = rt.plane(t1,b1,b2,t2,[1,0,0]);
  r[1][3] = rt.plane(t2,b2,b3,t3,[0,0,1]);
  r[1][4] = rt.plane(b3,b2,b1,b0,[0,-1,0]);
  r[1][5] = rt.plane(t3,b3,b0,t0,[-1,0,0]);
  r[1][6] = rt.plane(t0,b0,b1,t1,[0,0,-1]);

	for (let i = 1; i <= 6; i++){
		r[0][i].textureNums = new Array(6).fill([-1,1,-1]).flat();
		// Make second cuboid smooth.
		r[1][i].textureNums = new Array(6).fill([-1,3,0]).flat();
	}
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
	rt.queue.push(objects, box);
	// Start render engine.
	rt.render();

	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
	setInterval(async function(){
		fpsCounter.textContent = rt.FPS;
    // Update textures every second.
		rt.updateTextures();
		rt.updatePbrTextures();
    rt.updateTranslucencyTextures();
	},1000);
});