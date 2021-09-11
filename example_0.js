"use strict";
// Declare RayTracer global.
var rt;
// Wait until DOM is loaded.
document.addEventListener("DOMContentLoaded", function(){
	// Create new canvas.
	var canvas = document.createElement("canvas");
	// Append it to body.
	document.body.appendChild(canvas);
	// Create new RayTracer (rt) for canvas.
	rt = RayTracer(canvas);
	// Reduce Scale for better performance.
	rt.SCALE = 1;
	// Set two light sources.
	rt.LIGHT = [[0, 10, 0], [5, 5, 5]];
	// Modify brightness of first one to be dimmer (default is 3)
	rt.LIGHT[0].strength = 1;
	// Generate plane.
	let this_plane = rt.PLANE([-100,-1,-100],[100,-1,-100],[100,-1,100],[-100,-1,100],[0,1,0]);
	// Generate a few cuboids on the planes with bounding box.
	let r = [];
	r[0] = rt.CUBOID(-1.5, -1, 1.5, 6, 3, 1);
	r[1] = rt.CUBOID(-1.5, -1, -2, 3, 3, 1);
	r[2] = rt.CUBOID(0.5, -1, -1, 1, 3, 1);
	r[3] = rt.CUBOID(-1.5, -1, - 1, 1, 3, 1);
	// Color all cuboid in center.
	for (let i = 0; i < 4; i++){
		let color = new Array(6).fill([Math.random(), Math.random(), Math.random(), 1]).flat();
		for (let j = 1; j < 7; j++) r[i][j].colors = color;
	}
	// Spawn cube.
	let cube = rt.CUBOID(5.5, 1.5, 5.5, 1, 1, 1);
	// Package cube and cuboids together in a shared bounding volume.
	let objects = [
	  [-1.5, 6.5, -1, 2.5, -2, 6.5],
	  [[-1.5, 4.5, -1, 2, -2, 2.5], r[0], r[1], r[2], r[3]],
	  cube
	];
	// Push both objects to render queue.
	rt.QUEUE.push(this_plane, objects);
	// Start render engine.
	rt.START();

	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
	setInterval(function(){
		fpsCounter.textContent = rt.FPS;
	},100/6);
});
