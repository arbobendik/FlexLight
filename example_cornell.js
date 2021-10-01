"use strict";
// Declare RayTracer global.
var rt;
// Wait until DOM is loaded.
document.addEventListener("DOMContentLoaded", async function(){
	// Create new canvas.
	var canvas = document.createElement("canvas");
	// Append it to body.
	document.body.appendChild(canvas);
	// Create new RayTracer (rt) for canvas.
	rt = RayTracer(canvas);
  // Set position and perspective.

	// Create 2 options for texture roughness.
	let roughTex = await rt.GENERATE_NORMAL_TEX([255], 1, 1);
  let metallicTex = await rt.GENERATE_NORMAL_TEX([0], 1, 1);
	rt.NORMAL_TEXTURE.push(roughTex, metallicTex);

  // Move camera out of center.
  rt.Z = -20;

	// Set light source.
	rt.LIGHT = [[0, 4.9, 0]];
	// Modify brightness of first one to be brighter (default is 20)
	rt.LIGHT[0].strength = 4;

	// Generate side planes.
	let bottom_plane = rt.PLANE([-5,-5,-15],[5,-5,-15],[5,-5,5],[-5,-5,5],[0,1,0]);
  let top_plane = rt.PLANE([-5,5,-15],[-5,5,5],[5,5,5],[5,5,-15],[0,-1,0]);
  let back_plane = rt.PLANE([-5,-5,5],[5,-5,5],[5,5,5],[-5,5,5],[0,0,-1]);
  let left_plane = rt.PLANE([-5,-5,-15],[-5,-5,5],[-5,5,5],[-5,5,-15],[1,0,0]);
  let right_plane = rt.PLANE([5,-5,-15],[5,5,-15],[5,5,5],[5,-5,5],[-1,0,0]);
  // Make planes diffuse.
	bottom_plane.textureNums = new Array(6).fill([-1,0]).flat();
  top_plane.textureNums = new Array(6).fill([-1,0]).flat();
  left_plane.textureNums = new Array(6).fill([-1,0]).flat();
  right_plane.textureNums = new Array(6).fill([-1,0]).flat();
  // Color left and right plane.
  left_plane.colors = new Array(6).fill([1, 0, 0, 1]).flat();
  right_plane.colors = new Array(6).fill([0, 1, 0, 1]).flat();
	// Generate a few cuboids in the box with respective bounding box.
	let r = [];
  // Make first cuboid full defuse.
	r[0] = rt.CUBOID(-3, -1.5, -5, -2, -1, 1);

  let surfaces = new Array(2);
	let [x, x2, y, y2, z, z2] = [1, 3, -5, -1, -2, 2];
  surfaces[0] = [x, x2, y, y2, z, z2];
	// x2 z
  surfaces[1] = rt.PLANE([x,y2,z],[x2-1,y2,z+1],[x2,y2,z2],[x,y2,z2-1],[0,1,0]);
  surfaces[2] = rt.PLANE([x2-1,y2,z+1],[x2-1,y,z+1],[x2,y,z2],[x2,y2,z2],[1,0,0]);
  surfaces[3] = rt.PLANE([x2,y2,z2],[x2,y,z2],[x,y,z2-1],[x,y2,z2-1],[0,0,1]);
  surfaces[4] = rt.PLANE([x,y,z2-1],[x2,y,z2],[x2-1,y,z+1],[x,y,z],[0,-1,0]);
  surfaces[5] = rt.PLANE([x,y2,z2-1],[x,y,z2-1],[x,y,z],[x,y2,z],[-1,0,0]);
  surfaces[6] = rt.PLANE([x,y2,z],[x,y,z],[x2-1,y,z+1],[x2-1,y2,z+1],[0,0,-1]);
  r[1] = surfaces;

	for (let i = 1; i < 6; i++) r[1][i].textureNums = new Array(6).fill([-1,0]).flat();
	// Package cube and cuboids together in a shared bounding volume.
	let objects = [
    [-3, 3, -5, 0, -3, 3],
    r[0], r[1]
	];
	// Push both objects to render queue.
	rt.QUEUE.push(bottom_plane, top_plane, back_plane, left_plane, right_plane, objects);
	// Start render engine.
	rt.START();

	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
	setInterval(function(){
		fpsCounter.textContent = rt.FPS;
		rt.UPDATE_NORMAL_TEXTURE();
	},1000);
});
